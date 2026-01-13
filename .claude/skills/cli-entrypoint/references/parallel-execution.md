# Parallel Execution Patterns with ProcessPoolExecutor

ProcessPoolExecutorを使用した並列処理パターン。エンティティ単位（店舗、商品グループ、ユーザー等）で独立した処理を並列実行する。

## 基本構造

```python
from concurrent.futures import ProcessPoolExecutor, as_completed
from multiprocessing import cpu_count, get_context
from pathlib import Path

def run_process(
    input_path: Path,
    output_path: Path,
    entity_ids: list[str] | None,
    max_workers: int | None,
) -> None:
    """Run processing for all entities in parallel."""

    # ワーカー数決定
    if max_workers is None:
        max_workers = cpu_count()

    # 並列実行
    with ProcessPoolExecutor(
        max_workers=max_workers,
        mp_context=get_context("spawn")  # 重要: spawn でプロセス分離
    ) as executor:
        futures = []
        for entity_id in entity_ids:
            future = executor.submit(
                _run_worker,
                entity_id=entity_id,
                input_path=input_path,
                output_path=output_path,
                # DTOやシンプルなオブジェクトのみ渡す（pickle可能）
            )
            futures.append((entity_id, future))

        # 進捗表示
        _process_futures(futures)
```

## ワーカー関数パターン

```python
import traceback

def _run_worker(
    entity_id: str,
    input_path: Path,
    output_path: Path,
    # その他のパラメータ
) -> tuple[str, bool, str | None]:
    """Worker function: executed in each process.

    Returns:
        (entity_id, success, error_message)
    """
    try:
        # 1. 各プロセスで独立してデータロード
        loader = DataLoader()
        data = loader.load(input_path)

        # 2. エンティティでフィルタ
        entity_data = data.filter_by_entity(entity_id)

        # 3. 空データチェック
        if entity_data.is_empty():
            return (entity_id, False, "No valid data for entity")

        # 4. 処理実行
        processor = create_processor()
        result = processor.process(entity_data)

        if not result.success:
            return (entity_id, False, result.error_message)

        # 5. 保存
        save_dir = output_path / f"entity_id={entity_id}"
        save_dir.mkdir(parents=True, exist_ok=True)
        result.save(save_dir)

        return (entity_id, True, None)

    except KeyboardInterrupt:
        raise  # Ctrl+C は即座に伝播

    except Exception as e:
        error_msg = f"{type(e).__name__}: {str(e)}\\n{traceback.format_exc()}"
        return (entity_id, False, error_msg)
```

### 返り値パターン

```python
tuple[str, bool, str | None]
# (entity_id, success, error_message)
#
# entity_id: 処理対象のエンティティID
# success: 処理成功/失敗
# error_message: エラー時のメッセージ（成功時はNone）
```

## 進捗表示パターン

```python
from typing import Any

def _process_futures(
    futures: list[tuple[str, Any]],
) -> None:
    """Process futures and show progress."""
    completed = 0
    total = len(futures)
    failed_entities = []

    for future in as_completed([f for _, f in futures]):
        completed += 1
        try:
            entity_id_result, success, error = future.result(timeout=None)
            if success:
                print(f"  [{completed}/{total}] Completed: {entity_id_result}")
            else:
                print(f"  [{completed}/{total}] Failed: {entity_id_result}")
                if error:
                    print(f"      Error: {error[:200]}")
                failed_entities.append((entity_id_result, error))
        except Exception as e:
            err_msg = f"{type(e).__name__}: {str(e)[:80]}"
            print(f"  [{completed}/{total}] Process error: {err_msg}")
            failed_entities.append((f"unknown_{completed}", str(e)))

    # サマリー表示
    print("\\n" + "=" * 70)
    if failed_entities:
        print(f"  {len(failed_entities)} out of {total} entities failed")
        print("\\nFailed entities:")
        for entity_id, error in failed_entities:
            print(f"  - {entity_id}: {error[:100] if error else 'Unknown error'}")
    else:
        print(f"  All {total} entities completed successfully!")
    print("=" * 70)
```

## 重要なポイント

### 1. mp_context="spawn"

```python
with ProcessPoolExecutor(
    max_workers=max_workers,
    mp_context=get_context("spawn")  # 必須
) as executor:
```

**理由**:
- `fork` はマルチスレッドと相性が悪い（デッドロック等）
- `spawn` は確実にプロセス分離（新しいPythonインタープリタ起動）
- macOS/Windows では `spawn` がデフォルト、Linux では `fork` がデフォルト

### 2. pickle可能なオブジェクトのみ渡す

```python
# Good: DTOやシンプルなオブジェクト
future = executor.submit(
    _run_worker,
    entity_id=entity_id,
    product_group_map=SkuProductGroupMap(data=lf),  # DTO
    holiday_record=HolidayRecord(data=lf),  # DTO
    alpha=1e-4,  # プリミティブ型
)

# Bad: 複雑なオブジェクト
future = executor.submit(
    _run_worker,
    trainer=trainer,  # pickleできない可能性
    model=model,  # pickleできない可能性
)
```

### 3. KeyboardInterrupt の即座伝播

```python
try:
    # 処理
    ...
except KeyboardInterrupt:
    raise  # 重要: Ctrl+C を即座に伝播
except Exception as e:
    # その他のエラーハンドリング
    ...
```

### 4. エラーメッセージの制限

```python
error_msg = f"{type(e).__name__}: {str(e)}\\n{traceback.format_exc()}"
return (entity_id, False, error_msg)

# 表示時は長さ制限
print(f"  Error: {error[:200]}")
```

## トラブルシューティング

| 問題 | 原因 | 解決策 |
|------|------|--------|
| pickleエラー | 複雑なオブジェクトをワーカーに渡している | DTOやシンプルなオブジェクトのみ渡す |
| プロセスがハング | fork問題 | `mp_context=get_context("spawn")` を使用 |
| 進捗が表示されない | バッファリング | `print(..., flush=True)` を使用 |
| エラーが握りつぶされる | try-except が広すぎる | KeyboardInterrupt は即座にraise |
| メモリ不足 | max_workers が多すぎる | `cpu_count()` の半分に制限 |

## 応用パターン

### パターン1: 条件付き並列処理

```python
# エンティティ数が少ない場合は逐次実行
if len(entity_ids) < 3:
    for entity_id in entity_ids:
        result = _run_worker(entity_id, ...)
        # 処理
else:
    # 並列実行
    with ProcessPoolExecutor(...) as executor:
        ...
```

### パターン2: タイムアウト付き

```python
for future in as_completed([f for _, f in futures]):
    try:
        entity_id, success, error = future.result(timeout=3600)  # 1時間
    except TimeoutError:
        print(f"Timeout: {entity_id}")
        failed_entities.append((entity_id, "Timeout after 1 hour"))
```

### パターン3: チャンクサイズ調整

```python
# エンティティが多い場合、チャンクに分割
chunk_size = 100
for i in range(0, len(entity_ids), chunk_size):
    chunk = entity_ids[i:i + chunk_size]
    with ProcessPoolExecutor(...) as executor:
        # チャンク単位で並列処理
        ...
```

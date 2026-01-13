# Environment Configuration Patterns

環境別（ローカル/SageMaker/その他クラウド）のパス・設定管理パターン。

## 基本パターン: 環境別パス定数

### SageMaker固定パス

```python
from pathlib import Path

# SageMaker Processing Job の標準パス
SAGEMAKER_BASE = Path("/opt/ml/processing")
SAGEMAKER_INPUT = SAGEMAKER_BASE / "input"
SAGEMAKER_OUTPUT = SAGEMAKER_BASE / "output"

# 入力パス（処理種別共通）
SAGEMAKER_DATA_INPUT = SAGEMAKER_INPUT / "data"
SAGEMAKER_CONFIG_INPUT = SAGEMAKER_INPUT / "config"

# 出力パス（処理種別ごと）
SAGEMAKER_RESULT_OUTPUT = SAGEMAKER_OUTPUT / "result"
SAGEMAKER_ARTIFACTS_OUTPUT = SAGEMAKER_OUTPUT / "artifacts"
```

### ローカル可変パス

ローカル実行時はすべてCLIオプションで指定:

```python
@click.option(
    "--input_data_path",
    type=click.Path(exists=True, path_type=Path),
    required=True,
    help="Path to the input data",
)
@click.option(
    "--output_path",
    type=click.Path(exists=False, path_type=Path),
    required=True,
    help="Path to the output directory",
)
```

## ネストしたサブコマンド構造

```python
@click.group()
def cli() -> None:
    """Pipeline CLI."""
    pass

# ============================================================================
# local Group - パス指定必須
# ============================================================================

@cli.group()
def local() -> None:
    """Run pipeline locally with explicit paths."""
    pass

@local.command("process")
@local_input_path_options  # パス指定オプション
def local_process(
    input_data_path: Path,
    output_path: Path,
    ...
):
    """Process data locally."""
    run_process(
        input_path=input_data_path,
        output_path=output_path,
        ...
    )

# ============================================================================
# sagemaker Group - 固定パス使用
# ============================================================================

@cli.group()
def sagemaker() -> None:
    """Run pipeline on SageMaker with fixed paths."""
    pass

@sagemaker.command("process")
@common_options  # パス指定不要
def sagemaker_process(...):
    """Process data on SageMaker."""
    run_process(
        input_path=SAGEMAKER_DATA_INPUT,  # 固定パス
        output_path=SAGEMAKER_RESULT_OUTPUT,  # 固定パス
        ...
    )
```

## run関数の統一インターフェース

環境によらず同じrun関数を呼び出す:

```python
def run_process(
    input_path: Path,
    output_path: Path,
    entity_ids: list[str] | None,
    max_workers: int | None,
    # その他のパラメータ
) -> None:
    """Run processing for all entities in parallel.

    環境に依存しない統一インターフェース。
    local/sagemaker から同じ関数を呼び出す。
    """
    print("=" * 70)
    print("Pipeline Execution")
    print("=" * 70)
    print(f"\\nInput path: {input_path}")
    print(f"Output path: {output_path}")
    print(f"Max workers: {max_workers or cpu_count()}")
    print("=" * 70)

    # データロード
    loader = DataLoader()
    data = loader.load(input_path)

    # エンティティID取得
    if entity_ids is None:
        entity_ids = data.get_all_entity_ids()

    # 並列処理
    with ProcessPoolExecutor(...) as executor:
        ...
```

## 環境検出パターン（オプション）

環境を自動検出する場合:

```python
def detect_environment() -> str:
    """Detect execution environment."""
    if Path("/opt/ml/processing").exists():
        return "sagemaker"
    elif os.getenv("AWS_BATCH_JOB_ID"):
        return "aws_batch"
    elif os.getenv("KUBERNETES_SERVICE_HOST"):
        return "kubernetes"
    else:
        return "local"

def get_paths_for_environment(env: str) -> tuple[Path, Path]:
    """Get input/output paths based on environment."""
    if env == "sagemaker":
        return (SAGEMAKER_INPUT, SAGEMAKER_OUTPUT)
    elif env == "aws_batch":
        return (AWS_BATCH_INPUT, AWS_BATCH_OUTPUT)
    else:
        raise ValueError(f"Cannot auto-detect paths for environment: {env}")
```

**注意**: 自動検出は便利だが、明示的な環境選択（サブコマンド）の方が誤実行防止に有効。

## 使用例

### ローカル実行

```bash
python scripts/entrypoint.py local process \
  --input_data_path /path/to/input \
  --output_path /path/to/output \
  --max_workers 8
```

### SageMaker実行

```bash
# パス指定不要（固定パス使用）
python scripts/entrypoint.py sagemaker process \
  --max_workers 8
```

## 複数環境対応のベストプラクティス

### 1. 固定パスは定数で定義

```python
# Good: 定数で一箇所管理
SAGEMAKER_INPUT = Path("/opt/ml/processing/input")

# Bad: ハードコード
input_path = Path("/opt/ml/processing/input")  # 複数箇所で使うとNG
```

### 2. 環境ごとにサブグループ作成

```python
# Good: 環境を明示的に選択
cli.group("local")
cli.group("sagemaker")

# Bad: フラグで切り替え
@click.option("--sagemaker", is_flag=True)  # 誤実行リスク
```

### 3. run関数は環境非依存

```python
# Good: 環境に依存しない統一インターフェース
def run_process(input_path: Path, output_path: Path, ...):
    # ローカルでもSageMakerでも同じロジック
    ...

# Bad: 環境判定を内部で行う
def run_process(...):
    if detect_environment() == "sagemaker":
        input_path = SAGEMAKER_INPUT  # run関数内で環境判定するとテスト困難
    ...
```

## SageMaker Processing Job 標準パス

```
/opt/ml/processing/
├── input/               # 入力データ
│   ├── data/           # S3からダウンロードされたデータ
│   ├── config/         # 設定ファイル
│   └── model/          # モデルファイル（予測時）
└── output/              # 出力データ
    ├── result/         # 処理結果
    ├── artifacts/      # 中間生成物
    └── logs/           # ログ（オプション）
```

**SageMaker設定例（Python SDK）**:

```python
from sagemaker.processing import ProcessingInput, ProcessingOutput

processor.run(
    code="scripts/entrypoint.py",
    arguments=["sagemaker", "process", "--max_workers", "8"],
    inputs=[
        ProcessingInput(
            source="s3://bucket/input/data/",
            destination="/opt/ml/processing/input/data",
        ),
    ],
    outputs=[
        ProcessingOutput(
            source="/opt/ml/processing/output/result",
            destination="s3://bucket/output/result/",
        ),
    ],
)
```

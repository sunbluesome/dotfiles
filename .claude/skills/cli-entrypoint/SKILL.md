---
name: cli-entrypoint
description: Create CLI entrypoints for pipeline execution with local/SageMaker environment support and parallel processing. Use when user requests "CLI作成", "エントリーポイント", "entrypoint", "scripts/entrypoint.py", "コマンドライン実行", "local/sagemaker実行", "並列処理CLI", or needs to create command-line interfaces for data processing pipelines that support both local development and cloud (SageMaker) execution environments.
---

# CLI Entrypoint Creation

Create Click-based CLI entrypoints for executing pipelines in multiple environments (local/SageMaker).

## When to Use

- Creating `scripts/entrypoint.py` for pipeline execution
- Supporting both local development and SageMaker execution
- Parallel processing with ProcessPoolExecutor
- Entity-based parallel execution (stores, products, users, etc.)

## Quick Start

### Basic Structure

```python
"""Entrypoint for {Pipeline Name}.

Supports local (explicit paths) and SageMaker (fixed paths) execution.
"""
from __future__ import annotations

from concurrent.futures import ProcessPoolExecutor, as_completed
from multiprocessing import cpu_count, get_context
from pathlib import Path
from typing import Any, Callable

import click

# Import project components
from pipelines import YourPipeline
from data_io import ParquetLoader
# ...

# SageMaker Path Constants
SAGEMAKER_BASE = Path("/opt/ml/processing")
SAGEMAKER_INPUT = SAGEMAKER_BASE / "input"
SAGEMAKER_OUTPUT = SAGEMAKER_BASE / "output"

SAGEMAKER_DATA_INPUT = SAGEMAKER_INPUT / "data"
SAGEMAKER_RESULT_OUTPUT = SAGEMAKER_OUTPUT / "result"

# CLI Option Decorators
def common_options(f: Callable[..., Any]) -> Callable[..., Any]:
    @click.option("--max_workers", type=click.INT, default=None)
    @wraps(f)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return f(*args, **kwargs)
    return wrapper

# Worker Function
def _run_worker(entity_id: str, ...) -> tuple[str, bool, str | None]:
    try:
        # Process entity
        ...
        return (entity_id, True, None)
    except KeyboardInterrupt:
        raise
    except Exception as e:
        return (entity_id, False, str(e))

# Run Function
def run_process(...) -> None:
    with ProcessPoolExecutor(
        max_workers=max_workers or cpu_count(),
        mp_context=get_context("spawn")
    ) as executor:
        futures = [(eid, executor.submit(_run_worker, eid, ...)) for eid in entity_ids]
        _process_futures(futures)

# CLI Commands
@click.group()
def cli() -> None:
    """Pipeline CLI."""
    pass

@cli.group()
def local() -> None:
    """Run locally with explicit paths."""
    pass

@local.command("process")
@common_options
@click.option("--input_path", type=click.Path(exists=True, path_type=Path), required=True)
@click.option("--output_path", type=click.Path(exists=False, path_type=Path), required=True)
def local_process(input_path: Path, output_path: Path, max_workers: int | None):
    """Process data locally."""
    run_process(input_path, output_path, max_workers=max_workers)

@cli.group()
def sagemaker() -> None:
    """Run on SageMaker with fixed paths."""
    pass

@sagemaker.command("process")
@common_options
def sagemaker_process(max_workers: int | None):
    """Process data on SageMaker."""
    run_process(SAGEMAKER_DATA_INPUT, SAGEMAKER_RESULT_OUTPUT, max_workers=max_workers)

if __name__ == "__main__":
    cli()
```

## Implementation Steps

### 1. Define SageMaker Path Constants

固定パスを定数で定義:

```python
SAGEMAKER_BASE = Path("/opt/ml/processing")
SAGEMAKER_INPUT = SAGEMAKER_BASE / "input"
SAGEMAKER_OUTPUT = SAGEMAKER_BASE / "output"

# 入力パス
SAGEMAKER_DATA_INPUT = SAGEMAKER_INPUT / "data"
SAGEMAKER_CONFIG_INPUT = SAGEMAKER_INPUT / "config"

# 出力パス
SAGEMAKER_RESULT_OUTPUT = SAGEMAKER_OUTPUT / "result"
```

### 2. Create Option Decorators

オプション定義を再利用可能なデコレータに:

```python
from functools import wraps

def common_options(f: Callable[..., Any]) -> Callable[..., Any]:
    """共通オプション"""
    @click.option("--entity_filter", type=click.STRING, default=None)
    @click.option("--max_workers", type=click.INT, default=None)
    @wraps(f)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return f(*args, **kwargs)
    return wrapper

def local_input_path_options(f: Callable[..., Any]) -> Callable[..., Any]:
    """ローカル入力パスオプション"""
    @click.option("--input_path", type=click.Path(exists=True, path_type=Path), required=True)
    @click.option("--output_path", type=click.Path(exists=False, path_type=Path), required=True)
    @wraps(f)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return f(*args, **kwargs)
    return wrapper
```

詳細: [references/click-patterns.md](references/click-patterns.md)

### 3. Implement Worker Function

```python
def _run_worker(
    entity_id: str,
    input_path: Path,
    output_path: Path,
    # その他のパラメータ
) -> tuple[str, bool, str | None]:
    """Worker function: executed in each process."""
    try:
        # 1. Load data
        loader = DataLoader()
        data = loader.load(input_path)

        # 2. Filter by entity
        entity_data = data.filter_by_entity(entity_id)

        # 3. Check empty data
        if entity_data.is_empty():
            return (entity_id, False, "No valid data")

        # 4. Process
        pipeline = create_pipeline()
        result = pipeline.run(entity_data)

        # 5. Save
        save_dir = output_path / f"entity_id={entity_id}"
        save_dir.mkdir(parents=True, exist_ok=True)
        result.save(save_dir)

        return (entity_id, True, None)

    except KeyboardInterrupt:
        raise
    except Exception as e:
        error_msg = f"{type(e).__name__}: {str(e)}\\n{traceback.format_exc()}"
        return (entity_id, False, error_msg)
```

詳細: [references/parallel-execution.md](references/parallel-execution.md)

### 4. Implement Run Function

```python
def run_process(
    input_path: Path,
    output_path: Path,
    entity_ids: list[str] | None,
    max_workers: int | None,
) -> None:
    """Run processing for all entities in parallel."""

    # Load data
    loader = DataLoader()
    data = loader.load(input_path)

    # Get entity IDs
    if entity_ids is None:
        entity_ids = data.get_all_entity_ids()

    # Determine worker count
    if max_workers is None:
        max_workers = cpu_count()

    # Parallel execution
    with ProcessPoolExecutor(
        max_workers=max_workers,
        mp_context=get_context("spawn")
    ) as executor:
        futures = []
        for entity_id in entity_ids:
            future = executor.submit(_run_worker, entity_id, input_path, output_path)
            futures.append((entity_id, future))

        _process_futures(futures)
```

### 5. Define CLI Commands

```python
@click.group()
def cli() -> None:
    """Pipeline CLI."""
    pass

# Local group
@cli.group()
def local() -> None:
    """Run locally with explicit paths."""
    pass

@local.command("process")
@common_options
@local_input_path_options
def local_process(input_path: Path, output_path: Path, ...):
    """Process data locally."""
    run_process(input_path, output_path, ...)

# SageMaker group
@cli.group()
def sagemaker() -> None:
    """Run on SageMaker with fixed paths."""
    pass

@sagemaker.command("process")
@common_options
def sagemaker_process(...):
    """Process data on SageMaker."""
    run_process(SAGEMAKER_DATA_INPUT, SAGEMAKER_RESULT_OUTPUT, ...)
```

## Usage Examples

### Local Execution

```bash
python scripts/entrypoint.py local process \
  --input_path /path/to/input \
  --output_path /path/to/output \
  --max_workers 8
```

### SageMaker Execution

```bash
# No path specification needed (uses fixed paths)
python scripts/entrypoint.py sagemaker process \
  --max_workers 8
```

## Key Patterns

### Nested Subcommand Structure

```
cli
├── local           # ローカル実行（パス指定必須）
│   └── process
└── sagemaker       # SageMaker実行（固定パス）
    └── process
```

利点:
- 環境を明示的に選択（誤実行防止）
- 環境別のパス・設定を分離
- 拡張性（新環境追加が容易）

### Progress Display

```python
def _process_futures(futures: list[tuple[str, Any]]) -> None:
    completed = 0
    total = len(futures)
    failed_entities = []

    for future in as_completed([f for _, f in futures]):
        completed += 1
        entity_id, success, error = future.result()
        if success:
            print(f"  [{completed}/{total}] Completed: {entity_id}")
        else:
            print(f"  [{completed}/{total}] Failed: {entity_id}")
            failed_entities.append((entity_id, error))

    # Summary
    if failed_entities:
        print(f"\\n{len(failed_entities)} out of {total} entities failed")
    else:
        print(f"\\nAll {total} entities completed successfully!")
```

## Important Points

1. **Use `mp_context="spawn"`**: Prevents fork-related issues
2. **Pass pickle-able objects only**: DTOs and simple objects
3. **Raise KeyboardInterrupt immediately**: Enable Ctrl+C
4. **Environment-independent run function**: Same logic for local/SageMaker

## References

- [references/click-patterns.md](references/click-patterns.md) - Click option decorators
- [references/parallel-execution.md](references/parallel-execution.md) - ProcessPoolExecutor patterns
- [references/environment-config.md](references/environment-config.md) - Environment-specific configuration

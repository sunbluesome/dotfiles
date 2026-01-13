# Click Option Decorator Patterns

Clickのオプション定義を再利用可能なデコレータとして整理するパターン。

## 基本パターン

### オプションデコレータの定義

```python
from functools import wraps
from typing import Any, Callable
import click

def model_options(f: Callable[..., Any]) -> Callable[..., Any]:
    """Model hyperparameter options (train only)."""

    @click.option(
        "--alpha_stage1",
        type=click.FLOAT,
        default=1e-4,
        help="Regularization parameter for Stage 1 (default: 1e-4)",
    )
    @click.option(
        "--alpha_stage2",
        type=click.FLOAT,
        default=1e-5,
        help="Regularization parameter for Stage 2 (default: 1e-5)",
    )
    @wraps(f)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return f(*args, **kwargs)

    return wrapper
```

### 使用方法

```python
@cli.command("train")
@model_options  # 複数のオプションをまとめて追加
@common_options
def train_command(alpha_stage1: float, alpha_stage2: float, ...):
    """Train models."""
    ...
```

## オプションカテゴリ

### 1. モデルオプション（train専用）

ハイパーパラメータ、学習設定等。

```python
def model_options(f: Callable[..., Any]) -> Callable[..., Any]:
    @click.option("--alpha", type=click.FLOAT, default=1e-4)
    @click.option("--l1_ratio", type=click.FloatRange(min=0, max=1), default=0.5)
    @click.option("--min_samples", type=click.INT, default=50)
    @wraps(f)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return f(*args, **kwargs)
    return wrapper
```

### 2. 共通オプション（train/predict共通）

product_group, seller_ids, max_workers等。

```python
def common_options(f: Callable[..., Any]) -> Callable[..., Any]:
    @click.option(
        "--product_group",
        type=click.STRING,
        required=True,
        help='Product group configuration as JSON (e.g., \'{"type_id": 2}\')',
    )
    @click.option(
        "--seller_ids",
        type=click.STRING,
        default=None,
        help="Comma-separated seller IDs to process (default: all sellers)",
    )
    @click.option(
        "--max_workers",
        type=click.INT,
        default=None,
        help="Maximum number of parallel workers (defaults to cpu_count())",
    )
    @wraps(f)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return f(*args, **kwargs)
    return wrapper
```

### 3. ローカル入力パスオプション

ローカル実行時のパス指定。

```python
def local_input_path_options(f: Callable[..., Any]) -> Callable[..., Any]:
    @click.option(
        "--sales_records_path",
        type=click.Path(exists=True, path_type=Path),
        required=True,
        help="Path to the sales records",
    )
    @click.option(
        "--weather_records_path",
        type=click.Path(exists=True, path_type=Path),
        required=True,
        help="Path to the weather records",
    )
    @click.option(
        "--output_path",
        type=click.Path(exists=False, path_type=Path),
        required=True,
        help="Path to the output directory",
    )
    @wraps(f)
    def wrapper(*args: Any, **kwargs: Any) -> Any:
        return f(*args, **kwargs)
    return wrapper
```

## Click型指定

| データ型 | Click型 | 例 |
|---------|---------|-----|
| 整数 | `click.INT` | `type=click.INT, default=50` |
| 浮動小数点 | `click.FLOAT` | `type=click.FLOAT, default=1e-4` |
| 範囲指定 | `click.FloatRange(min=0, max=1)` | `type=click.FloatRange(min=0, max=1)` |
| 文字列 | `click.STRING` | `type=click.STRING, default=None` |
| パス | `click.Path(exists=True, path_type=Path)` | ファイル/ディレクトリ存在チェック |
| タプル | `nargs=N` | `type=click.FLOAT, nargs=4` → tuple[float, ...] |

## ネストしたサブコマンド構造

```python
@click.group()
def cli() -> None:
    """Pipeline CLI."""
    pass

@cli.group()
def local() -> None:
    """Run pipeline locally."""
    pass

@cli.group()
def sagemaker() -> None:
    """Run pipeline on SageMaker."""
    pass

@local.command("train")
@model_options
def local_train(...):
    """Train models locally."""
    ...

@sagemaker.command("train")
@model_options
def sagemaker_train(...):
    """Train models on SageMaker."""
    ...
```

実行例:
```bash
# local group → train command
python entrypoint.py local train --alpha 1e-4 ...

# sagemaker group → predict command
python entrypoint.py sagemaker predict --product_group '{"id": 2}'
```

## 利点

1. **DRY原則**: オプション定義を一箇所で管理
2. **保守性**: オプション変更時、デコレータのみ修正
3. **可読性**: コマンド定義がシンプル
4. **再利用**: 複数コマンドで同じオプションを共有

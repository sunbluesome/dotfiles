---
name: data-io-impl
description: |
  Implement data I/O with immediate DTO conversion using ILoader/ISaver protocols.
  Use when: building data loaders, result savers, file handlers, model persistence, or any external I/O operations.
  Triggers: "loader", "saver", "I/O", "file", "parquet", "json", "csv", "persistence", "データ読込", "保存", "永続化", "読み書き".
  NOT for: data transformation (use processor-impl), business logic (use domain-impl).
---

# データI/O実装スキル

## 配置ルール

`data_io/` に配置し、`data_io/__init__.py` で公開する。

## 基本パターン

### Loader（読み込み）

```python
from typing import Generic, TypeVar
from pathlib import Path
import polars as pl
from interface import ILoader

T = TypeVar("T")

class ParquetLoader(ILoader[T], Generic[T]):
    """Parquetローダー - DTO型をDIで注入"""

    def __init__(self, record_type: type[T]) -> None:
        self._record_type = record_type

    def load(self, path: str | Path) -> T:
        """読み込み直後にDTOへ変換"""
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        # DTOからスキーマを取得（ClassVar属性）
        schema = getattr(self._record_type, "SCHEMA", None)
        hive_schema = getattr(self._record_type, "HIVE_SCHEMA", None)

        lf = pl.scan_parquet(
            path,
            schema=schema,
            hive_schema=hive_schema,
        )
        return self._record_type(data=lf)
```

### DTO側のスキーマ定義

DTOには以下の ClassVar を定義:
1. **カラム名定数**: 各カラム名を `ClassVar[str]` で定義
2. **SCHEMA**: 必須カラムのスキーマ（カラム名定数を使用）
3. **HIVE_SCHEMA**: Hiveパーティションのスキーマ（オプション）

```python
from typing import ClassVar
import polars as pl
from pydantic import BaseModel, ConfigDict

class SalesRecord(BaseModel):
    """売上レコードDTO"""

    model_config = ConfigDict(arbitrary_types_allowed=True)

    # カラム名定数（実装時にマジックストリングを排除）
    SELLER_ID: ClassVar[str] = "seller_id"
    DATE: ClassVar[str] = "date"
    QUANTITY: ClassVar[str] = "quantity"

    # Polarsスキーマ（カラム名定数を使用）
    SCHEMA: ClassVar[dict[str, pl.DataType]] = {
        SELLER_ID: pl.String,
        DATE: pl.Date,
        QUANTITY: pl.Float64,
    }

    # Hiveパーティションスキーマ（オプション）
    HIVE_SCHEMA: ClassVar[dict[str, pl.DataType]] = {
        SELLER_ID: pl.String,
    }

    data: pl.LazyFrame
```

**利用側でのカラム名アクセス**:
```python
# Good: ClassVar定数を使用
df.select(pl.col(SalesRecord.SELLER_ID))

# Bad: マジックストリング
df.select(pl.col("seller_id"))  # NG
```

### Saver（保存）

```python
from typing import Generic, TypeVar
from pathlib import Path
from interface import ISaver

T = TypeVar("T")

class ParquetSaver(ISaver[T], Generic[T]):
    """Parquetセーバー"""

    def save(self, data: T, destination: Path | str) -> None:
        """DTOをParquetとして保存"""
        dest = Path(destination)
        dest.parent.mkdir(parents=True, exist_ok=True)
        data.data.collect().write_parquet(dest)
```

## 公開API

`data_io/__init__.py` で外部利用クラスをエクスポート:

```python
from data_io.parquet_loader import ParquetLoader
from data_io.parquet_saver import ParquetSaver
from data_io.json_loader import JsonLoader
from data_io.json_saver import JsonSaver

__all__ = ["ParquetLoader", "ParquetSaver", "JsonLoader", "JsonSaver"]
```

## 直接ファイル操作は禁止

```python
# Bad: 直接操作
df = pl.read_parquet("data.parquet")  # NG

# Good: Loader/Saverを経由
from data_io import ParquetLoader
loader = ParquetLoader(SalesRecord)
data = loader.load("data.parquet")
```

## 詳細リファレンス

- **Protocol定義・Genericの使い方**: [references/patterns.md](references/patterns.md)
- **汎用実例集**: [references/examples.md](references/examples.md)

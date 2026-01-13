# Data I/O パターン集

## 目次

1. [Protocol定義](#protocol定義)
2. [Generic型の使い方](#generic型の使い方)
3. [ファイル形式別パターン](#ファイル形式別パターン)
4. [ファイル名サニタイズ](#ファイル名サニタイズ)
5. [エラーハンドリング](#エラーハンドリング)
6. [禁止パターン](#禁止パターン)

---

## Protocol定義

### ILoader（読み込み）

```python
# interface/i_loader.py
from typing import Protocol, TypeVar
from pathlib import Path

T_co = TypeVar("T_co", covariant=True)

class ILoader(Protocol[T_co]):
    """データ読み込みインターフェース"""

    def load(self, path: str | Path) -> T_co:
        """ファイルを読み込みDTOとして返す"""
        ...
```

### ISaver（保存）

```python
# interface/i_saver.py
from typing import Protocol, TypeVar
from pathlib import Path

T_contra = TypeVar("T_contra", contravariant=True)

class ISaver(Protocol[T_contra]):
    """データ保存インターフェース"""

    def save(self, data: T_contra, destination: Path | str) -> None:
        """データをファイルに保存"""
        ...
```

### 公開API

`interface/__init__.py` でエクスポート:

```python
from interface.i_loader import ILoader
from interface.i_saver import ISaver

__all__ = ["ILoader", "ISaver"]
```

---

## Generic型の使い方

### Loader実装

DTO型をコンストラクタで注入し、Generic型パラメータで型安全性を確保。

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
        """Parquetを読み込みDTOとして返す"""
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        # DTOからスキーマを取得（ClassVar属性）
        schema = getattr(self._record_type, "SCHEMA", None)
        hive_schema = getattr(self._record_type, "HIVE_SCHEMA", None)

        lf = pl.scan_parquet(path, schema=schema, hive_schema=hive_schema)
        return self._record_type(data=lf)
```

### Saver実装

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

        # DTOはdataプロパティでLazyFrameを持つ想定
        data.data.collect().write_parquet(dest)
```

### 使用例（DI）

```python
from schemas import SalesRecord
from data_io import ParquetLoader, ParquetSaver
from interface import ILoader, ISaver

# Loader: DTO型を注入
loader: ILoader[SalesRecord] = ParquetLoader(SalesRecord)
sales = loader.load("data/raw/sales.parquet")  # SalesRecord型

# Saver: 型パラメータを指定
saver: ISaver[SalesRecord] = ParquetSaver[SalesRecord]()
saver.save(sales, "data/output/sales.parquet")
```

---

## ファイル形式別パターン

### Parquet（大規模データ）

```python
import polars as pl
from typing import Generic, TypeVar
from pathlib import Path
from interface import ILoader, ISaver

T = TypeVar("T")

class ParquetLoader(ILoader[T], Generic[T]):
    def __init__(self, record_type: type[T]) -> None:
        self._record_type = record_type

    def load(self, path: str | Path) -> T:
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        # DTOからスキーマを取得
        schema = getattr(self._record_type, "SCHEMA", None)
        hive_schema = getattr(self._record_type, "HIVE_SCHEMA", None)

        lf = pl.scan_parquet(path, schema=schema, hive_schema=hive_schema)
        return self._record_type(data=lf)


class ParquetSaver(ISaver[T], Generic[T]):
    def save(self, data: T, destination: Path | str) -> None:
        dest = Path(destination)
        dest.parent.mkdir(parents=True, exist_ok=True)
        data.data.collect().write_parquet(dest)
```

### JSON（メタデータ、設定、状態）

```python
import json
from interface import ILoader, ISaver

class JsonLoader(ILoader[T], Generic[T]):
    """JSONローダー - DTO型をDIで注入"""

    def __init__(self, record_type: type[T]) -> None:
        self._record_type = record_type

    def load(self, path: str | Path) -> T:
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        with path.open(encoding="utf-8") as f:
            raw = json.load(f)
        return self._record_type.model_validate(raw)


class JsonSaver(ISaver[T], Generic[T]):
    """JSONセーバー"""

    def save(self, data: T, destination: Path | str) -> None:
        dest = Path(destination)
        dest.parent.mkdir(parents=True, exist_ok=True)

        with dest.open("w", encoding="utf-8") as f:
            json.dump(data.model_dump(), f, indent=2, ensure_ascii=False)
```

### CSV（互換性重視）

```python
import polars as pl
from interface import ILoader, ISaver

class CsvLoader(ILoader[T], Generic[T]):
    def __init__(self, record_type: type[T]) -> None:
        self._record_type = record_type

    def load(self, path: str | Path) -> T:
        lf = pl.scan_csv(path)
        return self._record_type(data=lf)


class CsvSaver(ISaver[T], Generic[T]):
    def save(self, data: T, destination: Path | str) -> None:
        dest = Path(destination)
        dest.parent.mkdir(parents=True, exist_ok=True)
        data.data.collect().write_csv(dest)
```

---

## ファイル名サニタイズ

ファイル名に使えない文字を安全に置換。`utils/filename.py` に配置。

```python
# utils/filename.py

class FilenameHandler:
    """ファイル名のサニタイズと復元"""

    @staticmethod
    def sanitize(name: str) -> str:
        """ファイル名をサニタイズ"""
        return name.replace("/", "__").replace("\\", "__")

    @staticmethod
    def restore(filename: str) -> str:
        """サニタイズを元に戻す"""
        return filename.replace("__", "/")
```

### 使用例

```python
from utils.filename import FilenameHandler
from interface import ISaver
from schemas import ModelState

class GroupedStateSaver:
    def __init__(self, state_saver: ISaver[ModelState]) -> None:
        self._saver = state_saver

    def save_all(self, states: dict[str, ModelState], base_path: Path) -> None:
        states_dir = base_path / "states"
        states_dir.mkdir(parents=True, exist_ok=True)

        for group_id, state in states.items():
            safe_name = FilenameHandler.sanitize(group_id)
            self._saver.save(state, states_dir / f"{safe_name}.json")
```

---

## エラーハンドリング

```python
from pathlib import Path
import polars as pl
from interface import ILoader

class SafeParquetLoader(ILoader[T], Generic[T]):
    def __init__(self, record_type: type[T]) -> None:
        self._record_type = record_type

    def load(self, path: str | Path) -> T:
        """安全なファイル読み込み"""
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        try:
            lf = pl.scan_parquet(path)
            return self._record_type(data=lf)
        except Exception as e:
            raise IOError(f"Failed to load {path}: {e}") from e
```

---

## 禁止パターン

### 1. 生DataFrame/LazyFrameを返す

```python
# Bad
def load(self, path: Path) -> pl.LazyFrame:
    return pl.scan_parquet(path)  # NG

# Good
def load(self, path: Path) -> RecordDTO:
    lf = pl.scan_parquet(path)
    return RecordDTO(data=lf)
```

### 2. 直接ファイル操作（Loader/Saverを経由しない）

```python
# Bad: 直接ファイル操作
df = pl.read_parquet("data.parquet")  # NG
df.write_parquet("output.parquet")     # NG

# Good: Loader/Saverを使用
from data_io import ParquetLoader, ParquetSaver

loader = ParquetLoader(SalesRecord)
data = loader.load("data.parquet")

saver = ParquetSaver[SalesRecord]()
saver.save(data, "output.parquet")
```

### 3. ディレクトリ作成時の exist_ok=False

```python
# Bad
dest.mkdir(parents=True)  # exist_ok=False がデフォルト

# Good
dest.mkdir(parents=True, exist_ok=True)  # 冪等性確保
```

### 4. ファイル名のサニタイズ忘れ

```python
# Bad: グループIDにスラッシュが含まれる可能性
path = states_dir / f"{group_id}.json"  # NG

# Good
safe_name = FilenameHandler.sanitize(group_id)
path = states_dir / f"{safe_name}.json"
```

### 5. Any型の使用

```python
# Bad
def load(self, path: Path) -> Any:  # NG
    ...
```

### 6. 例外の抑制

```python
# Bad
def load(self, path: Path) -> RecordDTO | None:
    try:
        ...
    except:  # NG
        return None
```

### 7. カラム名のマジックストリング

```python
# Bad: 文字列リテラルを直接使用
df.select(pl.col("seller_id"))  # NG
df.filter(pl.col("quantity") > 0)  # NG

# Good: DTOのClassVar定数を使用
from schemas import SalesRecord

df.select(pl.col(SalesRecord.SELLER_ID))
df.filter(pl.col(SalesRecord.QUANTITY) > 0)
```

### 8. DTOにカラム名定数がない

```python
# Bad: SCHEMAに文字列リテラルを直接使用
class SalesRecord(BaseModel):
    SCHEMA: ClassVar[dict[str, pl.DataType]] = {
        "seller_id": pl.String,  # NG
        "date": pl.Date,         # NG
    }

# Good: カラム名をClassVarで定義してSCHEMAで参照
class SalesRecord(BaseModel):
    SELLER_ID: ClassVar[str] = "seller_id"
    DATE: ClassVar[str] = "date"

    SCHEMA: ClassVar[dict[str, pl.DataType]] = {
        SELLER_ID: pl.String,
        DATE: pl.Date,
    }
```

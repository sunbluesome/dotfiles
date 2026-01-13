# Data I/O 汎用実例集

## 目次

1. [汎用Parquetローダー/セーバー](#汎用parquetローダーセーバー)
2. [汎用JSONローダー/セーバー](#汎用jsonローダーセーバー)
3. [モデル永続化](#モデル永続化)
4. [複合結果セーバー](#複合結果セーバー)

---

## 汎用Parquetローダー/セーバー

DTO型をコンストラクタで注入。DTOに定義された `SCHEMA` と `HIVE_SCHEMA` を使用してスキーマを指定。

### DTO定義（スキーマ付き）

カラム名を ClassVar[str] で定義し、SCHEMA で参照することでマジックストリングを排除。

```python
from typing import ClassVar
import polars as pl
from pydantic import BaseModel, ConfigDict

class SalesRecord(BaseModel):
    """売上レコードDTO"""

    model_config = ConfigDict(arbitrary_types_allowed=True)

    # カラム名定数
    SELLER_ID: ClassVar[str] = "seller_id"
    DATE: ClassVar[str] = "date"
    QUANTITY: ClassVar[str] = "quantity"

    # Polarsスキーマ（カラム名定数を使用）
    SCHEMA: ClassVar[dict[str, pl.DataType]] = {
        DATE: pl.Date,
        QUANTITY: pl.Float64,
    }

    # Hiveパーティションスキーマ
    HIVE_SCHEMA: ClassVar[dict[str, pl.DataType]] = {
        SELLER_ID: pl.String,
    }

    data: pl.LazyFrame
```

**利用例**:
```python
# Processor/Transformer内でカラム名を参照
from schemas import SalesRecord

df.select(pl.col(SalesRecord.SELLER_ID))  # Good
df.filter(pl.col(SalesRecord.QUANTITY) > 0)
```

### Loader

```python
from typing import Generic, TypeVar
from pathlib import Path
import polars as pl
from interface import ILoader

T = TypeVar("T")

class ParquetLoader(ILoader[T], Generic[T]):
    """汎用Parquetローダー - DTO型をDIで注入"""

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

### Saver

```python
from typing import Generic, TypeVar
from pathlib import Path
from interface import ISaver

T = TypeVar("T")

class ParquetSaver(ISaver[T], Generic[T]):
    """汎用Parquetセーバー"""

    def save(self, data: T, destination: Path | str) -> None:
        """DTOをParquetとして保存"""
        dest = Path(destination)
        dest.parent.mkdir(parents=True, exist_ok=True)
        data.data.collect().write_parquet(dest)
```

### 使用例

```python
from schemas import SalesRecord
from data_io import ParquetLoader, ParquetSaver
from interface import ILoader, ISaver

# Loader
loader: ILoader[SalesRecord] = ParquetLoader(SalesRecord)
sales = loader.load("data/raw/sales.parquet")

# Saver
saver: ISaver[SalesRecord] = ParquetSaver[SalesRecord]()
saver.save(sales, "data/output/sales.parquet")
```

---

## 汎用JSONローダー/セーバー

Pydantic DTOの読み書き。

### Loader

```python
import json
from typing import Generic, TypeVar
from pathlib import Path
from interface import ILoader

T = TypeVar("T")

class JsonLoader(ILoader[T], Generic[T]):
    """汎用JSONローダー - DTO型をDIで注入"""

    def __init__(self, record_type: type[T]) -> None:
        self._record_type = record_type

    def load(self, path: str | Path) -> T:
        """JSONを読み込みDTOとして返す"""
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        with path.open(encoding="utf-8") as f:
            raw = json.load(f)
        return self._record_type.model_validate(raw)
```

### Saver

```python
import json
from typing import Generic, TypeVar
from pathlib import Path
from interface import ISaver

T = TypeVar("T")

class JsonSaver(ISaver[T], Generic[T]):
    """汎用JSONセーバー"""

    def save(self, data: T, destination: Path | str) -> None:
        """DTOをJSONとして保存"""
        dest = Path(destination)
        dest.parent.mkdir(parents=True, exist_ok=True)

        with dest.open("w", encoding="utf-8") as f:
            json.dump(data.model_dump(), f, indent=2, ensure_ascii=False)
```

### 使用例

```python
from schemas import AppConfig
from data_io import JsonLoader, JsonSaver
from interface import ILoader, ISaver

# Loader
config_loader: ILoader[AppConfig] = JsonLoader(AppConfig)
config = config_loader.load("config/app.json")

# Saver
config_saver: ISaver[AppConfig] = JsonSaver[AppConfig]()
config_saver.save(config, "config/app_backup.json")
```

---

## モデル永続化

> **⚠️ 暫定実装**: このモデル永続化パターンはベストプラクティスが確立されていません。
> より良い方法（例: pickle/joblib、専用フォーマット、バージョニング対応など）が
> 見つかった場合は、このスキルを更新してください。

学習済みモデルの保存と復元。Loader/Saverを組み合わせて実装。

### ModelSaver

```python
from pathlib import Path
from interface import ISaver, IEstimator, ITransformer
from schemas import ModelMetadata, ModelState, TransformerState

class ModelSaver:
    """モデル永続化 - 状態をJSONで保存"""

    def __init__(
        self,
        metadata_saver: ISaver[ModelMetadata],
        state_saver: ISaver[ModelState],
        transformer_state_saver: ISaver[TransformerState] | None = None,
    ) -> None:
        self._metadata_saver = metadata_saver
        self._state_saver = state_saver
        self._transformer_state_saver = transformer_state_saver

    def save(
        self,
        model: IEstimator,
        path: Path,
        transformer: ITransformer | None = None,
    ) -> None:
        """モデルとTransformerを保存"""
        if not model.is_fitted:
            raise RuntimeError("Model must be fitted before saving")

        path.mkdir(parents=True, exist_ok=True)

        # メタデータ保存
        metadata = ModelMetadata(
            model_type=model.__class__.__name__,
            transformer_type=transformer.__class__.__name__ if transformer else None,
        )
        self._metadata_saver.save(metadata, path / "metadata.json")

        # モデル状態保存
        self._state_saver.save(model.get_state(), path / "model_state.json")

        # Transformer状態保存（存在する場合）
        if transformer and transformer.is_fitted and self._transformer_state_saver:
            self._transformer_state_saver.save(
                transformer.get_state(),
                path / "transformer_state.json",
            )
```

### ModelLoader

```python
from pathlib import Path
from interface import ILoader, IEstimator, ITransformer
from schemas import ModelMetadata, ModelState, TransformerState

class ModelLoader:
    """モデル永続化 - 状態をJSONから復元"""

    def __init__(
        self,
        metadata_loader: ILoader[ModelMetadata],
        state_loader: ILoader[ModelState],
        transformer_state_loader: ILoader[TransformerState] | None,
        model_factory: dict[str, type],
        transformer_factory: dict[str, type],
    ) -> None:
        self._metadata_loader = metadata_loader
        self._state_loader = state_loader
        self._transformer_state_loader = transformer_state_loader
        self._model_factory = model_factory
        self._transformer_factory = transformer_factory

    def load(self, path: Path) -> tuple[IEstimator, ITransformer | None]:
        """保存されたモデルを復元"""
        if not path.exists():
            raise FileNotFoundError(f"Model directory not found: {path}")

        # メタデータ読み込み
        metadata = self._metadata_loader.load(path / "metadata.json")

        # モデル復元
        model_state = self._state_loader.load(path / "model_state.json")
        model_cls = self._model_factory[metadata.model_type]
        model = model_cls.from_state(model_state)

        # Transformer復元（存在する場合）
        transformer = None
        transformer_path = path / "transformer_state.json"
        if (
            transformer_path.exists()
            and metadata.transformer_type
            and self._transformer_state_loader
        ):
            transformer_state = self._transformer_state_loader.load(transformer_path)
            transformer_cls = self._transformer_factory[metadata.transformer_type]
            transformer = transformer_cls.from_state(transformer_state)

        return model, transformer
```

### ファクトリ関数

> **⚠️ 暫定実装**: モデル永続化のファクトリ関数もベストプラクティスが確立されていません。
> DI コンテナや設定ベースのファクトリなど、より良いパターンがあれば更新してください。

```python
from data_io import JsonLoader, JsonSaver
from schemas import ModelMetadata, ModelState, TransformerState

def create_model_saver() -> ModelSaver:
    """標準構成のModelSaverを作成"""
    return ModelSaver(
        metadata_saver=JsonSaver[ModelMetadata](),
        state_saver=JsonSaver[ModelState](),
        transformer_state_saver=JsonSaver[TransformerState](),
    )


def create_model_loader(
    model_factory: dict[str, type],
    transformer_factory: dict[str, type],
) -> ModelLoader:
    """標準構成のModelLoaderを作成"""
    return ModelLoader(
        metadata_loader=JsonLoader(ModelMetadata),
        state_loader=JsonLoader(ModelState),
        transformer_state_loader=JsonLoader(TransformerState),
        model_factory=model_factory,
        transformer_factory=transformer_factory,
    )
```

---

## 複合結果セーバー

> **⚠️ 暫定実装**: 複合結果の保存パターンはベストプラクティスが確立されていません。
> ディレクトリ構造、ファイル命名規則、アトミック書き込みなど、
> より良い方法があれば更新してください。

パイプライン結果を複数ファイルに分割保存。

```python
from pathlib import Path
from interface import ISaver
from schemas import PipelineOutput, Predictions, Metrics, Metadata

class PipelineResultSaver:
    """パイプライン結果セーバー - 複数Saverを組み合わせ"""

    def __init__(
        self,
        predictions_saver: ISaver[Predictions],
        metrics_saver: ISaver[Metrics] | None = None,
        metadata_saver: ISaver[Metadata] | None = None,
    ) -> None:
        self._predictions_saver = predictions_saver
        self._metrics_saver = metrics_saver
        self._metadata_saver = metadata_saver

    def save(self, output: PipelineOutput, destination: Path) -> None:
        """結果を複数ファイルに分割保存"""
        destination.mkdir(parents=True, exist_ok=True)

        # 予測結果保存（必須）
        self._predictions_saver.save(
            output.predictions,
            destination / "predictions.parquet",
        )

        # メトリクス保存（オプション）
        if output.metrics and self._metrics_saver:
            self._metrics_saver.save(
                output.metrics,
                destination / "metrics.json",
            )

        # メタデータ保存（オプション）
        if output.metadata and self._metadata_saver:
            self._metadata_saver.save(
                output.metadata,
                destination / "metadata.json",
            )
```

### ファクトリ関数

```python
from data_io import ParquetSaver, JsonSaver
from schemas import Predictions, Metrics, Metadata

def create_pipeline_result_saver() -> PipelineResultSaver:
    """標準構成のPipelineResultSaverを作成"""
    return PipelineResultSaver(
        predictions_saver=ParquetSaver[Predictions](),
        metrics_saver=JsonSaver[Metrics](),
        metadata_saver=JsonSaver[Metadata](),
    )
```

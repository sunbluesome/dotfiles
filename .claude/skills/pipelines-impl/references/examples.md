# Pipelines 汎用実例集

## 目次

1. [基本パイプライン](#基本パイプライン)
2. [ETLパイプライン](#etlパイプライン)
3. [ML訓練パイプライン](#ml訓練パイプライン)
4. [ML予測パイプライン](#ml予測パイプライン)
5. [バッチ処理パイプライン](#バッチ処理パイプライン)

---

## 基本パイプライン

シンプルなデータ処理パイプライン。

```python
from interface import IProcessor, ISaver
from schemas import PipelineInput, PipelineOutput

class BasicPipeline:
    """基本的なデータ処理パイプライン"""

    def __init__(
        self,
        cleaner: IProcessor,
        enricher: IProcessor,
        result_saver: ISaver | None = None,
    ) -> None:
        self._cleaner = cleaner
        self._enricher = enricher
        self._result_saver = result_saver

    def run(self, input_data: PipelineInput) -> PipelineOutput:
        """パイプライン実行"""
        try:
            # Phase 1: クリーニング
            cleaned = self._cleaner.process(input_data.raw_data)

            # Phase 2: エンリッチ
            enriched = self._enricher.process(cleaned)

            # Phase 3: 保存（オプション）
            if self._result_saver:
                self._result_saver.save(enriched, input_data.output_path)

            return PipelineOutput(result=enriched, success=True)

        except Exception as e:
            return PipelineOutput(
                result=None,
                success=False,
                error_message=str(e),
            )

    @classmethod
    def create_default(cls) -> "BasicPipeline":
        """デフォルト構成で作成"""
        from processor import DataCleaner, DataEnricher

        return cls(
            cleaner=DataCleaner(),
            enricher=DataEnricher(),
        )
```

## ETLパイプライン

Extract-Transform-Loadパターン。

```python
from pathlib import Path
from interface import ILoader, ITransformer, ISaver
from schemas import ETLConfig, ETLResult

class ETLPipeline:
    """ETLパイプライン"""

    def __init__(
        self,
        extractor: ILoader,
        transformers: list[ITransformer],
        loader: ISaver,
    ) -> None:
        self._extractor = extractor
        self._transformers = transformers
        self._loader = loader

    def run(self, config: ETLConfig) -> ETLResult:
        """ETL実行"""
        try:
            # Extract
            raw_data = self._extract(config.source_path)

            # Transform
            transformed = self._transform(raw_data)

            # Load
            self._load(transformed, config.destination_path)

            return ETLResult(
                success=True,
                records_processed=len(transformed),
            )

        except Exception as e:
            return ETLResult(
                success=False,
                error_message=str(e),
            )

    def _extract(self, source: Path) -> RawData:
        """Extract phase"""
        return self._extractor.load(source)

    def _transform(self, data: RawData) -> TransformedData:
        """Transform phase - 全transformerを順次適用"""
        current = data
        for transformer in self._transformers:
            current = transformer.process(current)
        return current

    def _load(self, data: TransformedData, destination: Path) -> None:
        """Load phase"""
        self._loader.save(data, destination)
```

## ML訓練パイプライン

モデル訓練用パイプライン。

```python
from pathlib import Path
import traceback
from interface import IPreprocessor, IFeatureTransformer, IEstimator, IModelSaver
from schemas import TrainConfig, TrainResult

class TrainingPipeline:
    """ML訓練パイプライン"""

    def __init__(
        self,
        preprocessor: IPreprocessor,
        feature_transformer: IFeatureTransformer,
        model: IEstimator,
        model_saver: IModelSaver | None = None,
    ) -> None:
        self._preprocessor = preprocessor
        self._feature_transformer = feature_transformer
        self._model = model
        self._model_saver = model_saver

    def train(self, config: TrainConfig) -> TrainResult:
        """訓練を実行"""
        try:
            # Phase 1: 前処理
            cleaned = self._preprocessor.process(config.raw_features)

            # Phase 2: 特徴量変換（fit_transform）
            features = self._feature_transformer.fit_transform(
                fit_data=cleaned,
                data=cleaned,
            )

            # Phase 3: モデル学習
            self._model.fit(features, config.target)

            # Phase 4: モデル保存（オプション）
            if self._model_saver and config.model_output_path:
                self._model_saver.save(
                    model=self._model,
                    transformer=self._feature_transformer,
                    path=config.model_output_path,
                )

            return TrainResult(
                success=True,
                model_state=self._model.get_state(),
            )

        except Exception as e:
            return TrainResult(
                success=False,
                error_message=f"{type(e).__name__}: {e}\n{traceback.format_exc()}",
            )

    @property
    def model(self) -> IEstimator:
        """訓練済みモデル"""
        return self._model

    @property
    def transformer(self) -> IFeatureTransformer:
        """学習済みTransformer"""
        return self._feature_transformer
```

## ML予測パイプライン

学習済みモデルによる予測パイプライン。

```python
from interface import IPreprocessor, IFeatureTransformer, IEstimator, IModelLoader
from schemas import PredictConfig, PredictResult

class PredictionPipeline:
    """ML予測パイプライン"""

    def __init__(
        self,
        preprocessor: IPreprocessor,
        feature_transformer: IFeatureTransformer,  # 学習済み
        model: IEstimator,  # 学習済み
    ) -> None:
        self._preprocessor = preprocessor
        self._feature_transformer = feature_transformer
        self._model = model

    def predict(self, config: PredictConfig) -> PredictResult:
        """予測を実行"""
        try:
            # Phase 1: 前処理
            cleaned = self._preprocessor.process(config.raw_features)

            # Phase 2: 特徴量変換（transform only）
            features = self._feature_transformer.transform(cleaned)

            # Phase 3: 予測
            predictions = self._model.predict(features)

            return PredictResult(
                success=True,
                predictions=predictions,
            )

        except Exception as e:
            return PredictResult(
                success=False,
                error_message=str(e),
            )

    @classmethod
    def from_saved_model(
        cls,
        model_path: Path,
        loader: IModelLoader,
        preprocessor: IPreprocessor,
    ) -> "PredictionPipeline":
        """保存済みモデルから作成"""
        model, transformer = loader.load(model_path)
        return cls(
            preprocessor=preprocessor,
            feature_transformer=transformer,
            model=model,
        )
```

## バッチ処理パイプライン

大量データのバッチ処理。

```python
from typing import Iterator
from interface import IBatchLoader, IProcessor, IBatchSaver
from schemas import BatchConfig, BatchResult

class BatchProcessingPipeline:
    """バッチ処理パイプライン"""

    def __init__(
        self,
        loader: IBatchLoader,
        processor: IProcessor,
        saver: IBatchSaver,
        batch_size: int = 1000,
    ) -> None:
        self._loader = loader
        self._processor = processor
        self._saver = saver
        self._batch_size = batch_size

    def run(self, config: BatchConfig) -> BatchResult:
        """バッチ処理を実行"""
        total_processed = 0
        total_errors = 0

        try:
            for batch in self._iterate_batches(config.source_path):
                try:
                    # バッチを処理
                    processed = self._processor.process(batch)

                    # 結果を保存
                    self._saver.save_batch(processed, config.destination_path)

                    total_processed += len(batch)

                except Exception:
                    total_errors += len(batch)
                    continue

            return BatchResult(
                success=True,
                total_processed=total_processed,
                total_errors=total_errors,
            )

        except Exception as e:
            return BatchResult(
                success=False,
                error_message=str(e),
            )

    def _iterate_batches(self, source: Path) -> Iterator[BatchData]:
        """バッチを順次取得"""
        return self._loader.iterate_batches(source, self._batch_size)
```

# Pipelines パターン集

## 目次

1. [単一エントリーポイント](#単一エントリーポイント)
2. [ファクトリメソッド](#ファクトリメソッド)
3. [エラーハンドリング](#エラーハンドリング)
4. [フェーズ分割](#フェーズ分割)
5. [Trainer/Predictor分離](#trainerpredictor分離)
6. [禁止パターン](#禁止パターン)

---

## 単一エントリーポイント

パイプラインは単一のエントリーポイントを持つ。

```python
class DataPipeline:
    def run(self, input_data: InputDTO) -> OutputDTO:
        """パイプライン実行の単一エントリーポイント"""
        processed = self._preprocess(input_data)
        result = self._apply_model(processed)
        return self._build_output(result)
```

### 命名規則

| パイプライン種別 | メソッド名 |
|----------------|----------|
| 汎用 | `run()` |
| 訓練 | `train()` |
| 予測 | `predict()` |
| 処理 | `process()` |

## ファクトリメソッド

標準構成でパイプラインを作成するファクトリメソッドを提供。

```python
class TrainingPipeline:
    @classmethod
    def create_default(
        cls,
        config: PipelineConfig | None = None,
    ) -> "TrainingPipeline":
        """標準構成でパイプラインを作成"""
        cfg = config or PipelineConfig()

        return cls(
            preprocessor=DataPreprocessor(cfg.preprocess_config),
            model=LinearModel(cfg.model_config),
            result_saver=ParquetSaver() if cfg.save_results else None,
        )
```

## エラーハンドリング

最上位メソッドでのみtry-exceptし、出力DTOでエラー情報を返す。

```python
import traceback
from schemas import PipelineOutput

class DataPipeline:
    def run(self, input_data: InputDTO) -> PipelineOutput:
        """パイプライン実行"""
        try:
            processed = self._preprocess(input_data)
            result = self._apply_model(processed)

            if self._result_saver:
                self._result_saver.save(result, self._output_path)

            return PipelineOutput(
                result=result,
                success=True,
            )

        except Exception as e:
            return PipelineOutput(
                result=None,
                success=False,
                error_message=f"{type(e).__name__}: {str(e)}\n{traceback.format_exc()}",
            )
```

### 出力DTO

```python
from pydantic import BaseModel

class PipelineOutput(BaseModel):
    """パイプライン出力"""
    result: ResultDTO | None
    success: bool
    error_message: str | None = None
```

## フェーズ分割

プライベートメソッドでフェーズを整理。preprocess/postprocessは`IProcessor`を利用。

```python
class DataProcessingPipeline:
    def __init__(
        self,
        preprocessor: IProcessor[RawData, Features],
        model: IModel,
        postprocessor: IProcessor[RawPredictions, Predictions] | None = None,
    ) -> None:
        self._preprocessor = preprocessor
        self._model = model
        self._postprocessor = postprocessor

    def run(self, input_data: InputDTO) -> OutputDTO:
        # Phase 1: 前処理（生データ → 特徴量）
        features = self._step_preprocess(input_data)

        # Phase 2: モデル適用
        raw_predictions = self._step_predict(features)

        # Phase 3: 後処理（生予測 → 運用向け出力）
        predictions = self._step_postprocess(raw_predictions)

        return OutputDTO(predictions=predictions, success=True)

    def _step_preprocess(self, data: InputDTO) -> Features:
        """Phase 1: 前処理（委譲のみ）"""
        return self._preprocessor.process(data)

    def _step_predict(self, features: Features) -> RawPredictions:
        """Phase 2: モデル適用（委譲のみ）"""
        return self._model.predict(features)

    def _step_postprocess(self, raw: RawPredictions) -> Predictions:
        """Phase 3: 後処理（委譲のみ）"""
        if self._postprocessor is None:
            return raw  # type: ignore
        return self._postprocessor.process(raw)
```

### Postprocessorの用途

| 用途 | 例 |
|------|-----|
| フォーマット変換 | 内部表現 → API応答形式 |
| 集計・要約 | 詳細予測 → サマリ統計 |
| メタデータ付与 | 予測値 + タイムスタンプ・バージョン |
| フィルタリング | 信頼度閾値でのフィルタ |

## Trainer/Predictor分離

訓練と予測を別パイプラインに分離するパターン。

### Trainer

```python
class ModelTrainer:
    """訓練パイプライン"""

    def __init__(
        self,
        preprocessor: IProcessor[RawData, Features],
        model: IModel,
        postprocessor: IProcessor[RawPredictions, Predictions] | None = None,
        model_saver: ISaver[ModelState] | None = None,
    ) -> None:
        self._preprocessor = preprocessor
        self._model = model
        self._postprocessor = postprocessor
        self._model_saver = model_saver

    def train(self, data: TrainData) -> TrainResult:
        """訓練を実行"""
        features = self._preprocessor.process(data.features)
        self._model.fit(features, data.target)
        raw_predictions = self._model.predict(features)
        predictions = self._postprocess(raw_predictions)
        return TrainResult(predictions=predictions, success=True)

    def save(self, path: Path) -> None:
        """モデルを保存"""
        if self._model_saver:
            self._model_saver.save(self._model.get_state(), path)

    def _postprocess(self, raw: RawPredictions) -> Predictions:
        if self._postprocessor is None:
            return raw  # type: ignore
        return self._postprocessor.process(raw)

    @property
    def model(self) -> IModel:
        """訓練済みモデルを取得"""
        return self._model
```

### Predictor

```python
class ModelPredictor:
    """予測パイプライン"""

    def __init__(
        self,
        preprocessor: IProcessor[RawData, Features],
        model: IModel,  # 訓練済み
        postprocessor: IProcessor[RawPredictions, Predictions] | None = None,
    ) -> None:
        self._preprocessor = preprocessor
        self._model = model
        self._postprocessor = postprocessor

    def predict(self, data: PredictData) -> PredictResult:
        """予測を実行"""
        features = self._preprocessor.process(data.features)
        raw_predictions = self._model.predict(features)
        predictions = self._postprocess(raw_predictions)
        return PredictResult(predictions=predictions)

    def _postprocess(self, raw: RawPredictions) -> Predictions:
        if self._postprocessor is None:
            return raw  # type: ignore
        return self._postprocessor.process(raw)
```

### 依存関係図

```
TrainingPipeline
    │
    ├── IProcessor (processor/)      ← ステートレス変換
    │
    ├── ITransformer (transformer/)  ← ステートフル変換
    │
    ├── IModel (models/)             ← fit/predict
    │
    └── ISaver (data_io/)            ← 結果保存
```

## 禁止パターン

### 1. パイプライン内にビジネスロジック

```python
# Bad
class OrderPipeline:
    def run(self, order: Order) -> OrderResult:
        # NG: ビジネスロジックをパイプライン内に書いている
        if order.total > 10000:
            discount = order.total * 0.1
        else:
            discount = 0
        ...

# Good: domain/に委譲
class OrderPipeline:
    def run(self, order: Order) -> OrderResult:
        discount = self._discount_policy.calculate(order)  # 委譲
        ...
```

### 2. 具象クラスへの直接依存

```python
# Bad
def __init__(self):
    self._model = ConcreteModel()  # NG

# Good
def __init__(self, model: IEstimator):
    self._model = model  # Protocol依存
```

### 3. プライベートメソッド以外での例外処理

```python
# Bad
def _preprocess(self, data):
    try:
        ...
    except:  # NG: フェーズ内でtry-except
        pass

# Good: 最上位のrunメソッドでのみtry-except
```

### 4. Any型の使用

```python
# Bad
def run(self, data: Any) -> Any:  # NG
    ...
```

### 5. 直接のI/O操作

```python
# Bad
def run(self, data: InputDTO) -> OutputDTO:
    raw = pd.read_parquet("data.parquet")  # NG: 直接I/O
    ...

# Good: data_io/に委譲
def run(self, data: InputDTO) -> OutputDTO:
    raw = self._loader.load("data.parquet")  # 委譲
    ...
```

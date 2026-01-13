---
name: pipelines-impl
description: |
  Implement pipeline orchestration with step-based structure.
  Use when: building training/prediction pipelines, orchestrating multiple components.
  Triggers: "pipeline", "trainer", "predictor", "パイプライン", "ワークフロー", "オーケストレーション".
---

# パイプライン実装スキル

## 配置ルール

`src/pipelines/` に配置する。

## 設計原則（YAGNI/KISS/SRP）

### YAGNI (You Aren't Gonna Need It)
- **明示的に必要なステップのみ実装**
- 「将来の拡張」のための空メソッドや抽象層を作らない
- オプショナル処理（postprocessor等）は実際に必要になってから追加

### KISS (Keep It Simple, Stupid)
- **ステップメソッドは単純な委譲のみ**
- パイプライン内でビジネスロジックを書かない
- 複雑な条件分岐はドメインロジックへ移動

### SRP (Single Responsibility Principle)
- **Pipeline = オーケストレーションのみ**
- データ変換処理はProcessorへ
- ビジネスルールはDomainへ
- 各ステップメソッドは1つの責務のみ

## 基本構造

パイプラインは **ステップメソッド + エントリーポイント** で構成する。

```python
class Trainer:
    """訓練パイプライン"""

    def __init__(
        self,
        preprocessor: IProcessor[TrainInput, Features],
        model: Model,
        postprocessor: IProcessor[RawPredictions, Predictions] | None = None,
        saver: ModelSaver | None = None,
    ) -> None:
        self._preprocessor = preprocessor
        self._model = model
        self._postprocessor = postprocessor
        self._saver = saver

    def train(self, data: TrainInput, config: Config) -> TrainOutput:
        """エントリーポイント - 外部からDTOを受け取る"""
        # Step 1: 前処理
        features = self._step_preprocess(data, config)

        # Step 2: 学習
        self._step_fit(features)

        # Step 3: 予測（訓練データ）
        raw_predictions = self._step_predict(features)

        # Step 4: 後処理（運用向け変換）
        predictions = self._step_postprocess(raw_predictions)

        return TrainOutput(predictions=predictions, success=True)

    def save(self, path: Path) -> None:
        """モデル保存（別メソッド）"""
        if self._saver is None:
            raise RuntimeError("saver is not configured")
        self._saver.save(self._model.get_state(), path)

    # --- Step Methods ---

    def _step_preprocess(self, data: TrainInput, config: Config) -> Features:
        """Step 1: 前処理"""
        return self._preprocessor.preprocess(data, config)

    def _step_fit(self, features: Features) -> None:
        """Step 2: 学習"""
        self._model.fit(features)

    def _step_predict(self, features: Features) -> RawPredictions:
        """Step 3: 予測"""
        return self._model.predict(features)

    def _step_postprocess(self, raw: RawPredictions) -> Predictions:
        """Step 4: 後処理（運用向け変換）"""
        if self._postprocessor is None:
            return raw  # type: ignore
        return self._postprocessor.process(raw)
```

## 設計原則

### 1. DTOを外から渡す

```python
# Good: 外からDTO渡し
def train(self, sales: SalesRecord, weather: WeatherRecord) -> Output:
    ...

# パイプライン内でLoadしない
# Loaderはエントリーポイント（CLI/スクリプト）側で使う
```

### 2. ステップメソッドで分割

```python
def train(self, data: Input) -> Output:
    # 各ステップの流れが一目でわかる
    features = self._step_preprocess(data)
    self._step_fit(features)
    raw_predictions = self._step_predict(features)
    predictions = self._step_postprocess(raw_predictions)
    return Output(predictions=predictions, success=True)

def _step_preprocess(self, data: Input) -> Features:
    """委譲のみ - ロジックを書かない"""
    return self._preprocessor.process(data)

def _step_postprocess(self, raw: RawPredictions) -> Predictions:
    """後処理 - 運用向け変換"""
    if self._postprocessor is None:
        return raw
    return self._postprocessor.process(raw)
```

### 3. DIでコンポーネント注入

```python
def __init__(
    self,
    preprocessor: IProcessor[Input, Features],
    model: Model,
    postprocessor: IProcessor[RawPredictions, Predictions] | None = None,
    saver: Saver | None = None,
) -> None:
    self._preprocessor = preprocessor
    self._model = model
    self._postprocessor = postprocessor
    self._saver = saver
```

### 4. Trainer/Predictor分離

```python
# Trainer: 学習 + 保存
class Trainer:
    def train(self, data: TrainInput) -> TrainOutput: ...
    def save(self, path: Path) -> None: ...

# Predictor: 推論のみ（学習済みモデル必須）
class Predictor:
    def __init__(self, preprocessor, model, mapping): ...
    def predict(self, data: PredictInput) -> PredictOutput: ...
```

## 禁止パターン

- パイプライン内でビジネスロジックを書く（委譲のみ）
- パイプライン内でI/O操作（Loaderはエントリーポイントで）
- ステップメソッド内でtry-except（最上位のみ）

## 詳細リファレンス

- **パターン集**: [references/patterns.md](references/patterns.md)

# Interface 汎用実例集

## 目次

1. [Data I/O Protocol](#data-io-protocol)
2. [Processor Protocol](#processor-protocol)
3. [Calculator Protocol](#calculator-protocol)
4. [Transformer Protocol](#transformer-protocol)
5. [StatModel Protocol](#statmodel-protocol)
6. [Estimator Protocol](#estimator-protocol)
7. [Trainer/Predictor Protocol](#trainerpredictor-protocol)

---

## Data I/O Protocol

### ILoader

```python
from typing import Protocol, TypeVar, Generic
from pathlib import Path

T = TypeVar("T", covariant=True)

class ILoader(Protocol[T]):
    """データ読み込みインターフェース"""

    def load(self, path: str | Path) -> T:
        """指定パスからデータを読み込む

        Args:
            path: 読み込み元パス

        Returns:
            読み込んだDTO

        Raises:
            FileNotFoundError: ファイルが存在しない場合
            IOError: 読み込みに失敗した場合
        """
        ...
```

### ISaver

```python
from typing import Protocol, TypeVar
from pathlib import Path

T = TypeVar("T", contravariant=True)

class ISaver(Protocol[T]):
    """データ保存インターフェース"""

    def save(self, data: T, destination: str | Path) -> None:
        """データを指定パスに保存

        Args:
            data: 保存するDTO
            destination: 保存先パス

        Raises:
            IOError: 保存に失敗した場合
        """
        ...
```

### 実装例

```python
from interface import ILoader, ISaver
from schemas import SalesRecord

class ParquetLoader(ILoader[SalesRecord]):
    def __init__(self, record_type: type[SalesRecord]) -> None:
        self._record_type = record_type

    def load(self, path: str | Path) -> SalesRecord:
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"File not found: {path}")

        schema = getattr(self._record_type, "SCHEMA", None)
        hive_schema = getattr(self._record_type, "HIVE_SCHEMA", None)

        lf = pl.scan_parquet(path, schema=schema, hive_schema=hive_schema)
        return self._record_type(data=lf)
```

---

## Processor Protocol

### 定義

```python
from typing import Protocol, TypeVar

T_in = TypeVar("T_in", contravariant=True)
T_out = TypeVar("T_out", covariant=True)

class IProcessor(Protocol[T_in, T_out]):
    """ステートレス変換インターフェース

    Processor は以下を満たす:
    - 同じ入力には常に同じ出力（純粋関数）
    - 副作用なし（I/O禁止）
    - 状態を持たない（設定のみ保持可）
    """

    def process(self, data: T_in) -> T_out:
        """入力DTOを出力DTOに変換

        Args:
            data: 入力DTO

        Returns:
            変換後のDTO
        """
        ...
```

### 実装例

```python
from interface import IProcessor
from schemas import RawRecord, CleanRecord

class DataCleaner(IProcessor[RawRecord, CleanRecord]):
    """データクリーニング - ステートレス"""

    def __init__(self, fill_value: float = 0.0) -> None:
        self._fill_value = fill_value  # 設定のみ

    def process(self, data: RawRecord) -> CleanRecord:
        cleaned = data.data.fill_null(self._fill_value)
        return CleanRecord(data=cleaned)
```

---

## Calculator Protocol

### 定義

```python
from typing import Protocol, TypeVar

T_in = TypeVar("T_in", contravariant=True)
T_out = TypeVar("T_out", covariant=True)

class ICalculator(Protocol[T_in, T_out]):
    """数理モデルインターフェース - 学習なし、直接計算"""

    def calculate(self, data: T_in) -> T_out:
        """計算を実行

        Args:
            data: 入力パラメータ

        Returns:
            計算結果
        """
        ...
```

### 実装例: 価格計算モデル

```python
from interface import ICalculator
from schemas import PricingInput, PricingResult

class DynamicPricingCalculator(ICalculator[PricingInput, PricingResult]):
    """動的価格計算 - 需要に基づく価格設定"""

    def __init__(
        self,
        base_price: float,
        demand_elasticity: float = 1.5,
    ) -> None:
        self._base_price = base_price
        self._elasticity = demand_elasticity

    def calculate(self, data: PricingInput) -> PricingResult:
        # 需要に応じた価格調整
        demand_ratio = data.current_demand / data.baseline_demand
        adjustment = demand_ratio ** self._elasticity
        calculated_price = self._base_price * adjustment

        return PricingResult(
            base_price=self._base_price,
            calculated_price=calculated_price,
            adjustment_factor=adjustment,
        )
```

### 実装例: 最適化モデル

```python
from interface import ICalculator
from schemas import InventoryInput, OptimalOrder

class ReorderPointCalculator(ICalculator[InventoryInput, OptimalOrder]):
    """発注点計算 - 安全在庫を考慮した発注量決定"""

    def __init__(self, service_level: float = 0.95) -> None:
        self._service_level = service_level
        self._z_score = self._get_z_score(service_level)

    def calculate(self, data: InventoryInput) -> OptimalOrder:
        # 安全在庫 = z * σ * √L
        safety_stock = (
            self._z_score
            * data.demand_std
            * (data.lead_time ** 0.5)
        )

        # 発注点 = 平均需要 × リードタイム + 安全在庫
        reorder_point = data.avg_demand * data.lead_time + safety_stock

        return OptimalOrder(
            reorder_point=reorder_point,
            safety_stock=safety_stock,
            order_quantity=data.economic_order_quantity,
        )

    def _get_z_score(self, service_level: float) -> float:
        # 簡易実装（実際は scipy.stats.norm.ppf を使用）
        z_table = {0.90: 1.28, 0.95: 1.65, 0.99: 2.33}
        return z_table.get(service_level, 1.65)
```

---

## Transformer Protocol

### 定義

```python
from typing import Protocol, TypeVar

FitT = TypeVar("FitT", contravariant=True)
InT = TypeVar("InT", contravariant=True)
OutT = TypeVar("OutT", covariant=True)

class ITransformer(Protocol[FitT, InT, OutT]):
    """ステートフル変換インターフェース - fit/transform パターン"""

    @property
    def is_fitted(self) -> bool:
        """学習済みかどうか"""
        ...

    def fit(self, data: FitT) -> None:
        """学習データからパラメータを学習"""
        ...

    def transform(self, data: InT) -> OutT:
        """学習済みパラメータで変換

        Raises:
            RuntimeError: fit() が呼ばれていない場合
        """
        ...

    def fit_transform(self, fit_data: FitT, data: InT) -> OutT:
        """fit + transform を一括実行"""
        ...
```

### 実装例

```python
from interface import ITransformer
from schemas import NumericData, ScaledData

class StandardScaler(ITransformer[NumericData, NumericData, ScaledData]):
    """標準化スケーラー - 平均0、標準偏差1"""

    def __init__(self) -> None:
        self._is_fitted: bool = False
        self._mean: float = 0.0
        self._std: float = 1.0

    @property
    def is_fitted(self) -> bool:
        return self._is_fitted

    def fit(self, data: NumericData) -> None:
        values = data.values
        self._mean = sum(values) / len(values)
        variance = sum((x - self._mean) ** 2 for x in values) / len(values)
        self._std = variance ** 0.5 if variance > 0 else 1.0
        self._is_fitted = True

    def transform(self, data: NumericData) -> ScaledData:
        if not self._is_fitted:
            raise RuntimeError("StandardScaler is not fitted")
        scaled = [(v - self._mean) / self._std for v in data.values]
        return ScaledData(values=scaled)

    def fit_transform(self, fit_data: NumericData, data: NumericData) -> ScaledData:
        self.fit(fit_data)
        return self.transform(data)
```

---

## StatModel Protocol

### 定義

```python
from typing import Protocol, TypeVar

X = TypeVar("X", contravariant=True)
y = TypeVar("y", contravariant=True)
ResultT = TypeVar("ResultT", covariant=True)

class IStatModel(Protocol[X, y, ResultT]):
    """統計モデルインターフェース - fit() が Results を返す"""

    def fit(self, X: X, y: y) -> ResultT:
        """モデルを学習し、Results オブジェクトを返す

        Args:
            X: 特徴量
            y: ターゲット

        Returns:
            Results オブジェクト（summary, predict, pvalues 等を持つ）
        """
        ...


class IStatModelResults(Protocol):
    """統計モデルの結果"""

    def summary(self) -> str: ...
    def predict(self, X) -> "Predictions": ...
    @property
    def params(self) -> "Coefficients": ...
    @property
    def pvalues(self) -> "PValues": ...
    def conf_int(self, alpha: float = 0.05) -> "ConfidenceIntervals": ...
```

### 実装例: GLMラッパー

```python
import statsmodels.api as sm
from interface import IStatModel
from schemas import DesignMatrix, Target, GLMResults

class GammaGLM(IStatModel[DesignMatrix, Target, GLMResults]):
    """ガンマGLM - statsmodels のラッパー"""

    def __init__(self, link: str = "log") -> None:
        self._link = self._get_link(link)
        self._family = sm.families.Gamma(link=self._link)

    def fit(self, X: DesignMatrix, y: Target) -> GLMResults:
        model = sm.GLM(y.values, X.matrix, family=self._family)
        results = model.fit()

        return GLMResults(
            params=results.params.tolist(),
            pvalues=results.pvalues.tolist(),
            aic=results.aic,
            bic=results.bic,
            deviance=results.deviance,
            _statsmodels_results=results,  # 内部保持
        )

    def _get_link(self, link: str):
        links = {"log": sm.families.links.Log(), "identity": sm.families.links.Identity()}
        return links.get(link, sm.families.links.Log())


# GLMResults DTO
class GLMResults(BaseModel):
    """GLM結果DTO"""
    params: list[float]
    pvalues: list[float]
    aic: float
    bic: float
    deviance: float
    _statsmodels_results: Any = None  # 内部用

    model_config = ConfigDict(arbitrary_types_allowed=True)

    def summary(self) -> str:
        return str(self._statsmodels_results.summary())

    def predict(self, X: DesignMatrix) -> Predictions:
        values = self._statsmodels_results.predict(X.matrix)
        return Predictions(values=values.tolist())

    def conf_int(self, alpha: float = 0.05) -> ConfidenceIntervals:
        ci = self._statsmodels_results.conf_int(alpha)
        return ConfidenceIntervals(lower=ci[:, 0].tolist(), upper=ci[:, 1].tolist())
```

### IStatModel vs IEstimator の使い分け

| 用途 | 推奨 Interface | 理由 |
|------|---------------|------|
| p値や信頼区間が必要 | `IStatModel` | Results に推論情報 |
| 予測精度を最大化したい | `IEstimator` | 予測に特化 |
| モデル診断が重要 | `IStatModel` | summary() で診断可能 |
| 特徴量重要度が必要 | `IEstimator` | feature_importances_ 等 |
| GLM, OLS, ロジスティック | `IStatModel` | statsmodels パターン |
| RandomForest, XGBoost | `IEstimator` | scikit-learn パターン |

---

## Estimator Protocol

### 定義

```python
from typing import Protocol, TypeVar

X = TypeVar("X", contravariant=True)
y = TypeVar("y", contravariant=True)
R = TypeVar("R", covariant=True)

class IEstimator(Protocol[X, y, R]):
    """MLモデルインターフェース - fit/predict パターン"""

    @property
    def is_fitted(self) -> bool:
        """学習済みかどうか"""
        ...

    def fit(self, X: X, y: y) -> None:
        """学習を実行

        Args:
            X: 特徴量
            y: ターゲット
        """
        ...

    def predict(self, X: X) -> R:
        """予測を実行

        Args:
            X: 特徴量

        Returns:
            予測結果

        Raises:
            RuntimeError: fit() が呼ばれていない場合
        """
        ...

    def get_state(self) -> "ModelState":
        """内部状態をDTOとして取得（永続化用）"""
        ...
```

### 実装例

```python
from interface import IEstimator
from schemas import Features, Target, Predictions, ModelState

class LinearRegressor(IEstimator[Features, Target, Predictions]):
    """線形回帰モデル"""

    def __init__(self) -> None:
        self._is_fitted: bool = False
        self._coefficients: list[float] = []
        self._intercept: float = 0.0

    @property
    def is_fitted(self) -> bool:
        return self._is_fitted

    def fit(self, X: Features, y: Target) -> None:
        # 学習ロジック
        self._coefficients = self._compute_coefficients(X, y)
        self._intercept = self._compute_intercept(X, y)
        self._is_fitted = True

    def predict(self, X: Features) -> Predictions:
        if not self._is_fitted:
            raise RuntimeError("Model must be fitted before predicting")
        values = self._compute_predictions(X)
        return Predictions(values=values)

    def get_state(self) -> ModelState:
        if not self._is_fitted:
            raise RuntimeError("Model must be fitted before getting state")
        return ModelState(
            coefficients=self._coefficients.copy(),
            intercept=self._intercept,
        )
```

---

## Trainer/Predictor Protocol

訓練と予測を分離するパターン。パイプライン構成に適している。

### 定義

```python
from typing import Protocol, TypeVar

X = TypeVar("X", contravariant=True)
y = TypeVar("y", contravariant=True)
R = TypeVar("R", covariant=True)

class ITrainer(Protocol[X, y]):
    """訓練専用インターフェース"""

    def train(self, X: X, y: y) -> "TrainResult":
        """訓練を実行

        Returns:
            訓練結果（メトリクス等）
        """
        ...

    @property
    def model(self) -> IEstimator:
        """訓練済みモデルを取得"""
        ...

    def save(self, path: Path) -> None:
        """モデルを保存"""
        ...


class IPredictor(Protocol[X, R]):
    """予測専用インターフェース"""

    def predict(self, X: X) -> R:
        """予測を実行"""
        ...

    @classmethod
    def from_path(cls, path: Path) -> "IPredictor[X, R]":
        """保存済みモデルから生成"""
        ...
```

### 実装例

```python
from interface import ITrainer, IPredictor, IEstimator
from schemas import Features, Target, Predictions, TrainResult

class ModelTrainer(ITrainer[Features, Target]):
    """訓練パイプライン"""

    def __init__(
        self,
        preprocessor: IProcessor,
        model: IEstimator,
        saver: ISaver | None = None,
    ) -> None:
        self._preprocessor = preprocessor
        self._model = model
        self._saver = saver

    def train(self, X: Features, y: Target) -> TrainResult:
        processed = self._preprocessor.process(X)
        self._model.fit(processed, y)
        return TrainResult(success=True)

    @property
    def model(self) -> IEstimator:
        return self._model

    def save(self, path: Path) -> None:
        if self._saver:
            self._saver.save(self._model.get_state(), path)


class ModelPredictor(IPredictor[Features, Predictions]):
    """予測パイプライン"""

    def __init__(
        self,
        preprocessor: IProcessor,
        model: IEstimator,
    ) -> None:
        self._preprocessor = preprocessor
        self._model = model

    def predict(self, X: Features) -> Predictions:
        processed = self._preprocessor.process(X)
        return self._model.predict(processed)

    @classmethod
    def from_path(cls, path: Path, loader: ILoader) -> "ModelPredictor":
        state = loader.load(path)
        model = LinearRegressor.from_state(state)
        preprocessor = DefaultPreprocessor()
        return cls(preprocessor=preprocessor, model=model)
```

### 使い分けガイド

| シナリオ | 推奨パターン |
|---------|------------|
| シンプルなモデル | `IEstimator` 単体 |
| 訓練/予測を別プロセスで実行 | `ITrainer` + `IPredictor` |
| パイプラインでの構成 | `ITrainer` + `IPredictor` |
| 状態の永続化が必要 | `ITrainer.save()` + `IPredictor.from_path()` |

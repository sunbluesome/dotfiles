# Interface パターン集

## 目次

1. [Generic型とVariance](#generic型とvariance)
2. [レイヤー別Protocol設計](#レイヤー別protocol設計)
3. [状態管理パターン](#状態管理パターン)
4. [Trainer/Predictorパターン](#trainerpredictor-パターン)
5. [禁止パターン](#禁止パターン)

---

## Generic型とVariance

### Covariance（共変性）- 出力型

出力型には `covariant=True` を使用。サブタイプを返せる。

```python
from typing import Protocol, TypeVar

T_out = TypeVar("T_out", covariant=True)

class ILoader(Protocol[T_out]):
    def load(self, path: str) -> T_out: ...

# 使用例: ILoader[BaseRecord] に ILoader[SalesRecord] を代入可能
```

### Contravariance（反変性）- 入力型

入力型には `contravariant=True` を使用。スーパータイプを受け入れる。

```python
from typing import Protocol, TypeVar

T_in = TypeVar("T_in", contravariant=True)

class ISaver(Protocol[T_in]):
    def save(self, data: T_in, path: str) -> None: ...

# 使用例: ISaver[SalesRecord] に ISaver[BaseRecord] を代入可能
```

### 入出力両方

入力と出力の両方を持つ場合は、それぞれの variance を指定。

```python
from typing import Protocol, TypeVar, Generic

T_in = TypeVar("T_in", contravariant=True)
T_out = TypeVar("T_out", covariant=True)

class IProcessor(Protocol[T_in, T_out]):
    def process(self, data: T_in) -> T_out: ...
```

### Invariance（不変性）- 状態を持つ場合

状態として保持する型は invariant（デフォルト）を使用。

```python
from typing import Protocol, TypeVar, Generic

StateT = TypeVar("StateT")  # covariant/contravariant なし = invariant

class IStatefulTransformer(Protocol[StateT]):
    def get_state(self) -> StateT: ...
    def set_state(self, state: StateT) -> None: ...
```

---

## レイヤー別Protocol設計

### Layer 1: Data I/O

外部境界でのデータ読み書き。

```python
# i_loader.py
from typing import Protocol, TypeVar
from pathlib import Path

T_out = TypeVar("T_out", covariant=True)

class ILoader(Protocol[T_out]):
    """外部データ読み込み"""
    def load(self, path: str | Path) -> T_out: ...


# i_saver.py
from typing import Protocol, TypeVar
from pathlib import Path

T_in = TypeVar("T_in", contravariant=True)

class ISaver(Protocol[T_in]):
    """外部データ保存"""
    def save(self, data: T_in, destination: str | Path) -> None: ...
```

### Layer 2: Stateless

> **Note**: データ検証は DTO 側で Pydantic を使用（`@field_validator`, `@model_validator`）

#### IProcessor

```python
# i_processor.py
from typing import Protocol, TypeVar

T_in = TypeVar("T_in", contravariant=True)
T_out = TypeVar("T_out", covariant=True)

class IProcessor(Protocol[T_in, T_out]):
    """ステートレス変換

    - 同じ入力には常に同じ出力
    - 副作用なし
    - インスタンス変数は設定のみ（学習結果を保持しない）
    """
    def process(self, data: T_in) -> T_out: ...
```

#### ICalculator

```python
# i_calculator.py
from typing import Protocol, TypeVar

T_in = TypeVar("T_in", contravariant=True)
T_out = TypeVar("T_out", covariant=True)

class ICalculator(Protocol[T_in, T_out]):
    """数理モデル - 学習なし、直接計算

    用途:
    - 価格計算モデル
    - 最適化モデル
    - シミュレーション
    - 数式ベースの予測
    """
    def calculate(self, data: T_in) -> T_out: ...
```

### Layer 3: Stateful Transformation

学習（fit）が必要な変換。

```python
# i_transformer.py
from typing import Protocol, TypeVar

FitT = TypeVar("FitT", contravariant=True)
InT = TypeVar("InT", contravariant=True)
OutT = TypeVar("OutT", covariant=True)

class ITransformer(Protocol[FitT, InT, OutT]):
    """ステートフル変換 - fit/transform パターン

    - fit(): 学習データからパラメータを学習
    - transform(): 学習済みパラメータで変換
    - fit_transform(): fit + transform を一括実行
    """

    @property
    def is_fitted(self) -> bool:
        """学習済みかどうか"""
        ...

    def fit(self, data: FitT) -> None:
        """学習データからパラメータを学習"""
        ...

    def transform(self, data: InT) -> OutT:
        """学習済みパラメータで変換（fit前に呼ぶとエラー）"""
        ...

    def fit_transform(self, fit_data: FitT, data: InT) -> OutT:
        """fit + transform を一括実行"""
        ...

    def get_state(self) -> "TransformerState":
        """内部状態をDTOとして取得（永続化用）"""
        ...

    def set_state(self, state: "TransformerState") -> None:
        """DTOから内部状態を復元"""
        ...
```

### Layer 4: Models

#### IStatModel（統計モデル）

statsmodels パターン。`fit()` が Results オブジェクトを返す。

```python
# i_stat_model.py
from typing import Protocol, TypeVar

X = TypeVar("X", contravariant=True)
y = TypeVar("y", contravariant=True)
ResultT = TypeVar("ResultT", covariant=True)

class IStatModel(Protocol[X, y, ResultT]):
    """統計モデル - fit() が Results を返す

    用途: GLM, OLS, ロジスティック回帰（推論重視）
    Results: summary(), predict(), conf_int(), pvalues 等
    """
    def fit(self, X: X, y: y) -> ResultT: ...


class IStatModelResults(Protocol):
    """統計モデルの結果"""

    def summary(self) -> str:
        """モデルサマリー（係数、p値、診断情報）"""
        ...

    def predict(self, X) -> "Predictions":
        """予測"""
        ...

    @property
    def params(self) -> "Coefficients":
        """推定されたパラメータ"""
        ...

    @property
    def pvalues(self) -> "PValues":
        """p値"""
        ...

    def conf_int(self, alpha: float = 0.05) -> "ConfidenceIntervals":
        """信頼区間"""
        ...
```

#### IEstimator（MLモデル）

scikit-learn パターン。`fit()` は `None` を返し、状態を内部に保持。

```python
# i_estimator.py
from typing import Protocol, TypeVar

X = TypeVar("X", contravariant=True)
y = TypeVar("y", contravariant=True)
R = TypeVar("R", covariant=True)

class IEstimator(Protocol[X, y, R]):
    """MLモデル - fit/predict パターン

    用途: 回帰、分類、クラスタリング（予測精度重視）
    """

    @property
    def is_fitted(self) -> bool:
        """学習済みかどうか"""
        ...

    def fit(self, X: X, y: y) -> None:
        """学習を実行"""
        ...

    def predict(self, X: X) -> R:
        """予測を実行（fit前に呼ぶとエラー）"""
        ...

    def get_state(self) -> "ModelState":
        """内部状態をDTOとして取得（永続化用）"""
        ...
```

#### IStatModel vs IEstimator の使い分け

| 観点 | IStatModel | IEstimator |
|------|------------|------------|
| 目的 | 統計的推論 | 予測精度 |
| fit戻り値 | Results オブジェクト | None（内部状態変更） |
| 重要な出力 | p値、信頼区間、診断 | 予測値、精度指標 |
| 例 | GLM, OLS, ロジスティック | RandomForest, XGBoost, NN |

---

## 状態管理パターン

### is_fitted プロパティ

```python
class ITransformer(Protocol[FitT, InT, OutT]):
    @property
    def is_fitted(self) -> bool:
        """学習済みかどうか"""
        ...
```

### get_state / set_state

永続化可能な状態管理。

```python
class IStateful(Protocol[StateT]):
    def get_state(self) -> StateT:
        """内部状態をDTOとして取得"""
        ...

    def set_state(self, state: StateT) -> None:
        """DTOから内部状態を復元"""
        ...

    @classmethod
    def from_state(cls, state: StateT) -> "IStateful[StateT]":
        """状態から復元（ファクトリメソッド）"""
        ...
```

---

## Trainer/Predictor パターン

訓練と予測を別クラスに分離するパターン。

```python
# i_model.py に追加

class ITrainer(Protocol[X, y]):
    """訓練専用インターフェース"""

    def train(self, X: X, y: y) -> "TrainResult":
        """訓練を実行"""
        ...

    @property
    def model(self) -> IEstimator:
        """訓練済みモデルを取得"""
        ...


class IPredictor(Protocol[X, R]):
    """予測専用インターフェース"""

    def predict(self, X: X) -> R:
        """予測を実行"""
        ...
```

### 使い分け

| パターン | 用途 |
|---------|------|
| `IEstimator` | 単一クラスでfit/predict両方 |
| `ITrainer` + `IPredictor` | 訓練と予測を分離（パイプライン構成向け） |

---

## 禁止パターン

### 1. Any型の使用

```python
# Bad
class IProcessor(Protocol):
    def process(self, data: Any) -> Any: ...  # NG

# Good
class IProcessor(Protocol[T_in, T_out]):
    def process(self, data: T_in) -> T_out: ...
```

### 2. kwargs: Any の乱用

```python
# Bad
class ILoader(Protocol[T]):
    def load(self, path: Path, **kwargs: Any) -> T: ...  # NG

# Good - 明示的な引数
class ILoader(Protocol[T]):
    def load(self, path: Path) -> T: ...

# 許容 - 設定オブジェクトで渡す
class ILoader(Protocol[T]):
    def load(self, path: Path, config: LoadConfig | None = None) -> T: ...
```

### 3. 副作用を持つIProcessor

```python
# Bad
class IProcessor(Protocol[T_in, T_out]):
    def process(self, data: T_in) -> T_out:
        """内部でファイル書き込みや状態変更を行う"""  # NG
        ...
```

### 4. 冗長なProtocol定義

```python
# Bad - 複数のProtocolが同じパターン
class IBuilder(Protocol[T]):
    def build(self, data: InputDTO) -> T: ...

class IEnricher(Protocol[T]):
    def enrich(self, data: InputDTO) -> T: ...

# Good - IProcessorに統合
class IProcessor(Protocol[T_in, T_out]):
    def process(self, data: T_in) -> T_out: ...
```

### 5. 不適切なVariance

```python
# Bad - 出力型にcontravariant
T_out = TypeVar("T_out", contravariant=True)  # NG

class ILoader(Protocol[T_out]):
    def load(self, path: Path) -> T_out: ...

# Good
T_out = TypeVar("T_out", covariant=True)

class ILoader(Protocol[T_out]):
    def load(self, path: Path) -> T_out: ...
```

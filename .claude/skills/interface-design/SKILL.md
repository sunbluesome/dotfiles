---
name: interface-design
description: |
  Use immediately when user mentions: "Interface", "Protocol", "インターフェース", "プロトコル", "contract", "契約", "abstraction", "抽象化", "DI", "dependency injection", "Generic", "TypeVar".

  MUST USE this skill for:
  - Designing Protocol interfaces for dependency injection
  - Defining component contracts
  - Creating abstractions with Generic types
  - Any work in src/interface/ directory
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# Interface設計スキル

## 配置ルール

Protocolは `src/interface/` に配置する。**データフローのレイヤーに基づいて分類**:

```
src/interface/
├── __init__.py        # 公開API（すべてここからexport）
│
│ # Layer 1: Data I/O（外部境界）
├── i_loader.py        # ILoader - 外部データ読み込み
├── i_saver.py         # ISaver - 外部データ保存
│
│ # Layer 2: Stateless
├── i_processor.py     # IProcessor - 状態なし変換（純粋関数）
│
│ # Layer 3: Stateful
├── i_transformer.py   # ITransformer - fit/transform パターン
└── i_model.py         # IModel - fit/predict パターン
```

## レイヤー別責務

| レイヤー | Protocol | 責務 | メソッド |
|---------|----------|------|---------|
| Data I/O | `ILoader`, `ISaver` | 外部境界でのI/O | `load()`, `save()` |
| Stateless | `IProcessor` | 固定ルール変換 | `process()` |
| Stateful | `ITransformer` | 学習ベース変換 | `fit()`, `transform()` |
| Models | `IModel` | 予測モデル | `fit()`, `predict()` |

> **Note**: データ検証は DTO 側で Pydantic の `@field_validator`, `@model_validator` を使用。
> 専用の `IValidator` インターフェースは不要。

## 設計原則（YAGNI/KISS/SRP）

### YAGNI (You Aren't Gonna Need It)
- **実際に使われるメソッドのみ定義**
- 「将来必要かも」で拡張メソッドを追加しない
- 使用箇所が1つだけなら、Protocolではなく具象クラスを直接使う

### KISS (Keep It Simple, Stupid)
- **1 Protocol = 1〜3メソッド**
- 複雑な継承階層を作らない（単一Protocolを優先）
- メソッドシグネチャはシンプルに（引数は1〜3個）

### SRP (Single Responsibility Principle)
- **1 Protocol = 1責務**
- `ILoaderAndSaver` のような複合Protocolは作らない
- メソッド名が "and" を含む場合は分割を検討

## 基本Protocol定義

### ILoader（読み込み）

```python
from typing import Protocol, TypeVar
from pathlib import Path

T_out = TypeVar("T_out", covariant=True)

class ILoader(Protocol[T_out]):
    """外部データ読み込み"""
    def load(self, path: str | Path) -> T_out: ...
```

### ISaver（保存）

```python
from typing import Protocol, TypeVar, Generic
from pathlib import Path

T_in = TypeVar("T_in", contravariant=True)

class ISaver(Protocol[T_in]):
    """外部データ保存"""
    def save(self, data: T_in, destination: str | Path) -> None: ...
```

### IProcessor（ステートレス変換）

```python
from typing import Protocol, TypeVar

T_in = TypeVar("T_in", contravariant=True)
T_out = TypeVar("T_out", covariant=True)

class IProcessor(Protocol[T_in, T_out]):
    """ステートレス変換 - 同じ入力には常に同じ出力"""
    def process(self, data: T_in) -> T_out: ...
```

### ITransformer（ステートフル変換）

```python
from typing import Protocol, TypeVar

FitT = TypeVar("FitT", contravariant=True)
InT = TypeVar("InT", contravariant=True)
OutT = TypeVar("OutT", covariant=True)

class ITransformer(Protocol[FitT, InT, OutT]):
    """ステートフル変換 - fit/transform パターン"""

    @property
    def is_fitted(self) -> bool: ...

    def fit(self, data: FitT) -> None: ...
    def transform(self, data: InT) -> OutT: ...
    def fit_transform(self, fit_data: FitT, data: InT) -> OutT: ...
```

### IModel（予測モデル）

```python
from typing import Protocol, TypeVar

X = TypeVar("X", contravariant=True)
y = TypeVar("y", contravariant=True)
R = TypeVar("R", covariant=True)

class IModel(Protocol[X, y, R]):
    """予測モデル - fit/predict パターン

    - MLモデル: fit()で学習、predict()で予測
    - 統計モデル: fit()でGLM等の結果取得
    - 数理モデル: fit()はNotImplementedError、predict()で計算
    """

    @property
    def is_fitted(self) -> bool: ...

    def fit(self, X: X, y: y) -> None: ...
    def predict(self, X: X) -> R: ...
    def get_state(self) -> "ModelState": ...
```

**用途別の実装パターン:**
- **MLモデル**: fit()で学習、predict()で予測（標準パターン）
- **統計モデル**: fit()後に`_results`属性でsummary()やconf_int()にアクセス
- **数理モデル**: fit()で`raise NotImplementedError`、predict()で直接計算

## 命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| ファイル | `i_*.py` | `i_processor.py` |
| Protocol | `I*`プレフィックス | `IProcessor`, `ILoader` |
| メソッド | 動詞ベース | `load`, `save`, `process`, `fit`, `predict` |

## 継承ルール

- **ファイル間継承禁止** - Protocolの継承は同一ファイル内のみ許可
- **コンポジション優先** - 継承より依存注入を使用
- 例外: 具象クラスがProtocolを実装することは許可

## 禁止パターン

- `Any` 型の使用
- `**kwargs: Any` の乱用（明示的な引数を優先）
- 副作用を持つ `IProcessor`
- `fit()` なしの `transform()` 呼び出し
- Protocol未定義での実装開始
- 別ファイルのProtocolを継承する

## 詳細リファレンス

- **詳細パターン・Generic/Variance**: [references/patterns.md](references/patterns.md)
- **汎用実例集**: [references/examples.md](references/examples.md)

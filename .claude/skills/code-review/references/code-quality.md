# コード品質リファレンス

## アーキテクチャ準拠

### ディレクトリ別責務

| ディレクトリ | 責務 | 禁止事項 |
|-------------|------|---------|
| `schemas/` | DTO定義 | ロジック、I/O |
| `interface/` | Protocol定義 | 実装 |
| `processor/` | Stateless変換 | 状態保持、I/O |
| `transformer/` | Stateful変換 | fit前のtransform |
| `domain/` | ビジネスロジック | I/O |
| `models/` | ML models | I/O |
| `pipelines/` | オーケストレーション | ビジネスロジック |
| `data_io/` | 外部I/O | ロジック |
| `utils/` | 汎用ユーティリティ | ビジネスロジック |

### チェック質問

```
□ このファイルは適切なディレクトリにあるか？
□ ディレクトリの責務を逸脱していないか？
□ 依存方向は正しいか？（pipelines → domain → processor）
```

## 型安全性

### 必須ルール

```python
# NG: Any型
from typing import Any
def process(data: Any) -> Any:  # 禁止
    pass

# OK: 具体的な型
from schemas import SalesRecord
def process(data: SalesRecord) -> ProcessedRecord:
    pass

# NG: Optional[T]
from typing import Optional
def get(id: str) -> Optional[str]:  # 非推奨
    pass

# OK: T | None
def get(id: str) -> str | None:  # 推奨
    pass
```

### チェック質問

```
□ 公開APIに型注釈があるか？
□ Any型が使われていないか？
□ 返り値の型は具体的か？（dict, DataFrame禁止）
□ Union型は適切に使われているか？
```

## 不変性

### DTOの変更

```python
# NG: in-place変更
record.field = new_value

# OK: model_copy使用
new_record = record.model_copy(update={"field": new_value})
```

### DataFrameの変更

```python
# NG: in-place変更
df.drop(columns=["col"], inplace=True)
df["new_col"] = value  # 元のdfを変更

# OK: 新しいDataFrame作成
df = df.drop(columns=["col"])
df = df.with_columns(pl.lit(value).alias("new_col"))  # Polars
```

### チェック質問

```
□ DTOのin-place変更がないか？
□ DataFrameのinplace=Trueがないか？
□ 入力データを変更していないか？
□ Processorは副作用なしか？
```

## エラー処理

### 禁止パターン

```python
# NG: bare except
try:
    risky_operation()
except:  # 禁止
    pass

# NG: 例外無視
try:
    risky_operation()
except Exception:
    pass  # 禁止: 何もしない

# OK: 具体的な例外処理
try:
    risky_operation()
except ValueError as e:
    logger.warning(f"Invalid value: {e}")
    raise
```

### チェック質問

```
□ bare exceptがないか？
□ 例外を無視していないか？
□ 適切なログ出力があるか？
□ 例外は適切にre-raiseしているか？
```

## 命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| ファイル（DTO） | `s_*.py` | `s_sales_record.py` |
| ファイル（Interface） | `i_*.py` | `i_loader.py` |
| クラス（DTO） | PascalCase | `SalesRecord` |
| クラス（Interface） | `I*` | `ILoader` |
| 関数 | 動詞ベース | `calculate_total()` |
| 変数 | 説明的な名詞 | `sales_records` (not `sr`) |

## 禁止パターン検出

### Grep検索パターン

```bash
# Any型の使用
grep -r "from typing import Any" src/
grep -r ": Any" src/

# in-place変更
grep -r "inplace=True" src/
grep -r "inplace = True" src/

# bare except
grep -r "except:" src/

# Optional使用
grep -r "Optional\[" src/
```

### コード内パターン

```python
# 禁止: 生dict返却
def process() -> dict:  # 公開APIでは禁止
    return {"key": value}

# 禁止: 生DataFrame返却
def process() -> pd.DataFrame:  # 公開APIでは禁止
    return df

# OK: DTO返却
def process() -> ProcessedRecord:
    return ProcessedRecord(...)
```

## Processor vs Transformer

### 判断基準

| 特徴 | Processor | Transformer |
|------|-----------|-------------|
| 状態 | なし | あり（fit結果） |
| パターン | `process(in) → out` | `fit()` + `transform()` |
| ユースケース | 固定ルール変換 | 学習ベース変換 |
| 配置 | `processor/` | `transformer/` |

### チェック質問

```
□ この変換は固定ルールか、データから学習するか？
□ Processorに状態保持がないか？
□ Transformerでfitなしにtransformしていないか？
```

## 依存性注入

```python
# NG: 具象クラスに直接依存
class Pipeline:
    def __init__(self):
        self._loader = ConcreteLoader()  # 禁止

# OK: Interfaceに依存
class Pipeline:
    def __init__(self, loader: ILoader):
        self._loader = loader
```

### チェック質問

```
□ 新規コンポーネントにProtocolが定義されているか？
□ 具象クラスではなくProtocolに依存しているか？
□ DIでコンポーネントを注入しているか？
```

## チェックリスト総括

```
アーキテクチャ:
□ ファイルが適切なディレクトリにある
□ ディレクトリの責務を逸脱していない
□ 依存方向が正しい

型安全性:
□ 公開APIに型注釈がある
□ Any型がない
□ Optional[T]ではなくT | Noneを使用

不変性:
□ DTOのin-place変更がない
□ DataFrameのinplace=Trueがない
□ Processorが副作用なし

エラー処理:
□ bare exceptがない
□ 例外を無視していない

命名:
□ ファイル/クラス/関数の命名規則準拠

依存性:
□ Protocolに依存
□ DIで注入
```

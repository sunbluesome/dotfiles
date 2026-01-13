# BDD Testing パターン集

## 目次

1. [Contextクラス](#contextクラス)
2. [データテーブル変換](#データテーブル変換)
3. [正常系パターン](#正常系パターン)
4. [異常系パターン](#異常系パターン)
5. [数値・行列系テスト](#数値行列系テスト)
6. [日付系テスト](#日付系テスト)
7. [コンポーネント別テスト](#コンポーネント別テスト)

---

## Contextクラス

テスト状態を保持するクラス:

```python
from dataclasses import dataclass, field
from typing import Any

@dataclass
class Context:
    """テストコンテキスト"""
    data: dict[str, Any] = field(default_factory=dict)
    result: Any = None
    error: Exception | None = None

@pytest.fixture
def context() -> Context:
    return Context()
```

## データテーブル変換

Gherkinデータテーブルをdict/DataFrameに変換:

```python
import datetime
import polars as pl
from typing import Any

def parse_datatable(
    datatable: list[list[str]],
    schema: dict[str, pl.DataType],
) -> pl.DataFrame:
    """データテーブルをPolars DataFrameに変換"""
    headers = datatable[0]
    rows = datatable[1:]

    data_dict: dict[str, list[Any]] = {h: [] for h in headers}
    for row in rows:
        for i, h in enumerate(headers):
            val = row[i]
            # 型に応じた変換
            if h == "date":
                data_dict[h].append(datetime.date.fromisoformat(val))
            elif h == "quantity":
                data_dict[h].append(float(val))
            else:
                data_dict[h].append(val)

    return pl.DataFrame(data_dict, schema=schema)
```

## 正常系パターン

### 基本作成テスト

```gherkin
Scenario: 有効なデータでDTOを作成
  Given 以下の販売データがある
    | seller_id | sku_id | date       | quantity |
    | user1     | itemA  | 2023-01-01 | 10       |
  When SalesRecordを作成する
  Then DTOが正常に作成される
  And seller_id が "user1" である
```

### 境界値テスト

```gherkin
Scenario Outline: 境界値での動作確認
  Given 数量が <quantity> の販売データがある
  When SalesRecordを作成する
  Then <result>

  Examples:
    | quantity | result               |
    | 0        | DTOが正常に作成される |
    | 1        | DTOが正常に作成される |
    | 999999   | DTOが正常に作成される |
```

### オプショナルフィールド

```gherkin
Scenario: オプショナルフィールドが省略可能
  Given 必須フィールドのみの販売データがある
  When SalesRecordを作成する
  Then DTOが正常に作成される
  And product_group_type_id が null である
```

### プロパティ検証

```gherkin
Scenario: 日付範囲プロパティ
  Given 複数日付の販売データがある
    | seller_id | sku_id | date       | quantity |
    | user1     | itemA  | 2023-01-01 | 10       |
    | user1     | itemB  | 2023-01-15 | 20       |
  When SalesRecordを作成する
  Then date_min が "2023-01-01" である
  And date_max が "2023-01-15" である
```

## 異常系パターン

### 必須カラム欠落

```gherkin
Scenario: 必須カラム欠落でエラー
  Given quantity列が欠落した販売データがある
    | seller_id | sku_id | date       |
    | user1     | itemA  | 2023-01-01 |
  When SalesRecordを作成する
  Then ValueError が発生する
  And エラーメッセージに "Missing required columns" が含まれる
```

```python
@then(parsers.parse('エラーメッセージに "{fragment}" が含まれる'))
def step_check_error_message(context: Context, fragment: str) -> None:
    assert context.error is not None
    assert fragment in str(context.error)
```

### 型間違い

```gherkin
Scenario: 型間違いでエラー
  Given quantity が String型 の販売データがある
    | seller_id | sku_id | date       | quantity |
    | user1     | itemA  | 2023-01-01 | "10"     |
  When SalesRecordを作成する
  Then ValueError が発生する
  And エラーメッセージに "has type" が含まれる
```

```python
@given("quantity が String型 の販売データがある", target_fixture="context")
def step_given_wrong_type(context: Context, datatable: list[list[str]]) -> Context:
    # String型でDataFrame作成
    schema = {
        "seller_id": pl.String(),
        "sku_id": pl.String(),
        "date": pl.Date(),
        "quantity": pl.String(),  # Wrong type
    }
    # ...
```

### 無効値（null/inf/nan/negative）

```gherkin
Scenario Outline: 無効な数量でエラー
  Given 数量が <value_type> の販売データがある
  When SalesRecordを作成する
  Then ValueError が発生する

  Examples:
    | value_type |
    | null       |
    | negative   |
    | inf        |
    | nan        |
```

```python
import math

@given(parsers.parse("数量が {value_type} の販売データがある"), target_fixture="context")
def step_given_invalid_value(context: Context, value_type: str) -> Context:
    value_map = {
        "null": None,
        "negative": -1.0,
        "inf": float("inf"),
        "nan": float("nan"),
    }
    quantity = value_map[value_type]
    # DataFrameに設定
    # ...
```

### 空データ

```gherkin
Scenario: 空データで処理
  Given 空の販売データがある
  When Cleanerで処理する
  Then 空のSalesRecordが返される
```

## 数値・行列系テスト

### スカラー境界値

```gherkin
Scenario Outline: スカラー値の境界値テスト
  Given 値が <value> のパラメータがある
  When 処理を実行する
  Then <result>

  Examples:
    | value    | result                |
    | 0        | 正常に処理される       |
    | 1        | 正常に処理される       |
    | -1       | ValueError が発生する  |
    | 0.0001   | 正常に処理される       |
    | 1e10     | 正常に処理される       |
    | inf      | ValueError が発生する  |
    | -inf     | ValueError が発生する  |
    | nan      | ValueError が発生する  |
```

### ベクトル操作

```gherkin
Feature: ベクトル操作の検証

  # 正常系
  Scenario: 有効なベクトルで処理
    Given 長さ 100 のベクトルがある
    When 正規化処理を実行する
    Then 結果のL2ノルムが 1.0 である

  Scenario: 同一長さのベクトル演算
    Given 長さ 5 のベクトルAとBがある
    When 内積を計算する
    Then スカラー値が返される

  # 異常系
  Scenario: 空ベクトルでエラー
    Given 空のベクトルがある
    When 正規化処理を実行する
    Then ValueError が発生する

  Scenario: 長さ不一致でエラー
    Given 長さ 5 のベクトルAと長さ 3 のベクトルBがある
    When 内積を計算する
    Then ValueError が発生する

  Scenario: ゼロベクトルの正規化
    Given 全要素が 0 のベクトルがある
    When 正規化処理を実行する
    Then ValueError が発生する
```

```python
import numpy as np

@then(parsers.parse("結果のL2ノルムが {expected:g} である"))
def step_check_l2_norm(context: Context, expected: float) -> None:
    norm = np.linalg.norm(context.result)
    assert np.isclose(norm, expected)

@then("全要素が有限値である")
def step_check_finite(context: Context) -> None:
    assert np.all(np.isfinite(context.result))
```

### 行列操作

```gherkin
Feature: 行列操作の検証

  # 正常系
  Scenario: 有効な疎行列で処理
    Given 形状 (100, 50) の疎行列がある
    When DesignMatrixを作成する
    Then n_samples が 100 である
    And n_features が 50 である

  Scenario: 行列の結合
    Given 形状 (10, 3) と (10, 2) の行列がある
    When 水平結合する
    Then 結果の形状が (10, 5) である

  # 異常系
  Scenario: 行数不一致で結合エラー
    Given 形状 (10, 3) と (5, 2) の行列がある
    When 水平結合する
    Then ValueError が発生する

  Scenario: 空行列でエラー
    Given 形状 (0, 5) の空行列がある
    When 処理を実行する
    Then ValueError が発生する

  Scenario: 特徴量なしでエラー
    Given 形状 (10, 0) の行列がある
    When 処理を実行する
    Then ValueError が発生する
```

```python
from scipy import sparse as sp

@given(parsers.parse("形状 ({rows:d}, {cols:d}) の疎行列がある"), target_fixture="context")
def step_given_sparse_matrix(context: Context, rows: int, cols: int) -> Context:
    context.matrix = sp.csr_matrix(np.ones((rows, cols)))
    return context

@then(parsers.parse("結果の形状が ({rows:d}, {cols:d}) である"))
def step_check_shape(context: Context, rows: int, cols: int) -> None:
    assert context.result.shape == (rows, cols)
```

### 数値精度

```gherkin
Scenario: 浮動小数点の近似比較
  Given 計算結果 0.1 + 0.2 がある
  Then 結果が 0.3 に近似である

Scenario: 係数の非負制約
  Given lower_bound 0.0 で学習したモデルがある
  Then 全係数が非負である
```

```python
@then(parsers.parse("結果が {expected:g} に近似である"))
def step_check_approx(context: Context, expected: float) -> None:
    assert context.result == pytest.approx(expected)

@then("全係数が非負である")
def step_check_nonnegative(context: Context) -> None:
    coef = context.model.coef_
    assert np.all(coef >= -1e-6)  # 数値誤差を許容
```

## 日付系テスト

### 日付境界値

```gherkin
Feature: 日付境界値テスト

  Scenario Outline: 年境界での動作
    Given 日付が <date> のデータがある
    When 週番号を計算する
    Then 週番号が <week> である

    Examples:
      | date       | week |
      | 2023-01-01 | 52   |  # 前年の週
      | 2023-01-02 | 1    |  # 新年最初の週
      | 2023-12-31 | 52   |  # 年末

  Scenario Outline: 月境界での動作
    Given 日付が <date> のデータがある
    When 月初フラグを計算する
    Then 月初フラグが <is_first> である

    Examples:
      | date       | is_first |
      | 2023-01-01 | true     |
      | 2023-01-31 | false    |
      | 2023-02-01 | true     |

  Scenario: うるう年の2月29日
    Given 日付が 2024-02-29 のデータがある
    When 曜日を計算する
    Then 曜日が 4 である  # 木曜日
```

### 日付範囲

```gherkin
Feature: 日付範囲テスト

  Scenario: 日付範囲プロパティ
    Given 以下の日付データがある
      | date       |
      | 2023-01-15 |
      | 2023-01-01 |
      | 2023-12-31 |
    When レコードを作成する
    Then date_min が "2023-01-01" である
    And date_max が "2023-12-31" である

  Scenario: 単一日付の範囲
    Given 日付が 2023-06-15 のみのデータがある
    When レコードを作成する
    Then date_min と date_max が同じである
```

### 曜日・週テスト

```gherkin
Feature: 曜日・週計算テスト

  Scenario Outline: 曜日計算
    Given 日付が <date> のデータがある
    When 曜日を計算する
    Then 曜日が <wday> である

    Examples:
      | date       | wday |
      | 2023-01-01 | 7    |  # 日曜
      | 2023-01-02 | 1    |  # 月曜
      | 2023-01-07 | 6    |  # 土曜

  Scenario: 週の切り捨て
    Given 日付が 2023-01-05 のデータがある  # 木曜
    When 週開始日を計算する
    Then 週開始日が "2023-01-02" である  # 月曜
```

```python
import datetime

@given(parsers.parse("日付が {date_str} のデータがある"), target_fixture="context")
def step_given_date(context: Context, date_str: str) -> Context:
    context.date = datetime.date.fromisoformat(date_str)
    return context

@then(parsers.parse("曜日が {wday:d} である"))
def step_check_weekday(context: Context, wday: int) -> None:
    # isoweekday(): 月=1, 日=7
    assert context.result == wday

@then(parsers.parse('週開始日が "{expected}" である'))
def step_check_week_start(context: Context, expected: str) -> None:
    expected_date = datetime.date.fromisoformat(expected)
    assert context.result == expected_date
```

### 祝日・特殊日付

```gherkin
Feature: 祝日テスト

  Scenario: 祝日フラグの付与
    Given 以下のデータがある
      | date       |
      | 2023-01-01 |  # 元日
      | 2023-01-02 |  # 平日
    And 祝日カレンダーに "2023-01-01" がある
    When 祝日フラグを付与する
    Then "2023-01-01" は holiday=True である
    And "2023-01-02" は holiday=False である

  Scenario: 祝日カレンダーにない日付
    Given 日付 "2025-01-01" のデータがある
    And 祝日カレンダーが 2023年 のみ
    When 祝日フラグを付与する
    Then holiday=False である
```

## コンポーネント別テスト

### DTO テスト

```gherkin
Feature: SalesRecord DTO
  # 正常系
  Scenario: 有効なスキーマで作成
  Scenario: オプショナルカラム付きで作成
  Scenario: プロパティが正しく計算される

  # 異常系
  Scenario: 必須カラム欠落
  Scenario: 型間違い（String vs Float64）
  Scenario: 型間違い（Int32 vs Float64）
  Scenario: null値を含むデータ
```

### Processor テスト

```gherkin
Feature: SalesCleaner Processor
  # 正常系
  Scenario: 有効なレコードを保持
  Scenario: 複数レコードを正しく処理

  # 異常系
  Scenario: 非正の数量を除去
  Scenario: 空データを処理
```

### Transformer テスト

```gherkin
Feature: TemperatureMatrixTransformer
  # 正常系
  Scenario: fit_transformで設計行列作成
  Scenario: fitしてからtransform

  # 異常系
  Scenario: 未fitでtransformするとエラー
  Scenario: 空データでfit
```

### Model テスト

```gherkin
Feature: CategoryGLM Model
  # 正常系
  Scenario: fit後にpredict
  Scenario: 予測値が非負

  # 異常系
  Scenario: 未fitでpredictするとエラー
```

### Pipeline テスト

```gherkin
Feature: TwoStageTrainer Pipeline
  # 正常系
  Scenario: E2E訓練パイプライン
  Scenario: モデル保存

  # 異常系
  Scenario: 入力データ不正でエラー
  Scenario: 途中エラーが適切に伝播
```

## Step定義のベストプラクティス

### parsersの活用

```python
from pytest_bdd import parsers

# 整数パラメータ
@then(parsers.parse("レコード数が {count:d} である"))
def step_check_count(context: Context, count: int) -> None:
    assert len(context.result) == count

# 浮動小数点パラメータ
@then(parsers.parse("合計が {total:g} である"))
def step_check_total(context: Context, total: float) -> None:
    assert context.result.sum() == pytest.approx(total)

# 文字列パラメータ
@then(parsers.parse('名前が "{name}" である'))
def step_check_name(context: Context, name: str) -> None:
    assert context.result.name == name
```

### エラーチェック共通パターン

```python
@then(parsers.parse("{error_type} が発生する"))
def step_check_error_type(context: Context, error_type: str) -> None:
    assert context.error is not None, "Expected an error, but got None"
    assert type(context.error).__name__ == error_type

@then(parsers.parse('エラーメッセージに "{fragment}" が含まれる'))
def step_check_error_message(context: Context, fragment: str) -> None:
    assert context.error is not None
    assert fragment in str(context.error)
```

## 実行コマンド

```bash
# 全テスト実行
uv run pytest tests/ -v

# 特定モジュール
uv run pytest tests/src/schemas/ -v

# 特定feature
uv run pytest tests/src/schemas/test_s_records.py -v

# キーワードでフィルタ
uv run pytest -k "invalid" -v
```

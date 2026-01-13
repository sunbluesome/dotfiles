---
name: bdd-feature
description: |
  Use immediately when user mentions: "テスト", "test", "BDD", "feature", "フィーチャー", "scenario", "シナリオ", "Given", "When", "Then", "カバレッジ", "coverage", "pytest-bdd", "Gherkin".

  MUST USE this skill for:
  - Creating BDD feature files with Gherkin syntax
  - Implementing step definitions with pytest-bdd
  - Designing test scenarios and fixtures
  - Any work in tests/ directory
---

# BDD Testing スキル

## 配置ルール

```
tests/
├── features/           # Gherkin Feature files
│   └── <module>/       # src構造をミラー
│       └── <name>.feature
├── src/                # Step definitions
│   └── <module>/
│       └── test_<name>.py
└── conftest.py         # 共通fixtures
```

## 基本構造

### Feature ファイル

```gherkin
Feature: 販売記録DTOのバリデーション
  販売記録が正しく構築・検証されることを確認する

  # 正常系
  Scenario: 有効なデータでDTOを作成
    Given 以下の販売データがある
      | seller_id | sku_id | date       | quantity |
      | user1     | itemA  | 2023-01-01 | 10       |
    When SalesRecordを作成する
    Then DTOが正常に作成される

  # 異常系
  Scenario: 必須カラム欠落でエラー
    Given quantity列が欠落した販売データがある
    When SalesRecordを作成する
    Then ValueError が発生する
    And エラーメッセージに "Missing required columns" が含まれる
```

### Step definitions

```python
from pytest_bdd import given, when, then, scenarios, parsers

scenarios("schemas/s_sales_record.feature")

class Context:
    data: dict | None = None
    result: Any = None
    error: Exception | None = None

@pytest.fixture
def context() -> Context:
    return Context()

@given("以下の販売データがある", target_fixture="context")
def step_given_data(context: Context, datatable: list[list[str]]) -> Context:
    context.data = parse_datatable(datatable)
    return context

@when("SalesRecordを作成する")
def step_create_dto(context: Context) -> None:
    try:
        context.result = SalesRecord(**context.data)
    except Exception as e:
        context.error = e

@then("DTOが正常に作成される")
def step_check_success(context: Context) -> None:
    assert context.error is None
    assert isinstance(context.result, SalesRecord)

@then(parsers.parse("{error_type} が発生する"))
def step_check_error(context: Context, error_type: str) -> None:
    assert context.error is not None
    assert type(context.error).__name__ == error_type
```

## テストカテゴリ【必須網羅】

**重要**: 全コンポーネントで「正常系」「境界値」「異常系」の3カテゴリを必ず網羅すること。

### 必須チェックリスト

各コンポーネント実装時に以下を確認:

```
□ 正常系: 基本動作が正しく動くか？（最低1ケース）
□ 境界値: 端の値で正しく動くか？（0, 1, 空, 最大値など）
□ 異常系: 不正入力でエラーが発生するか？（null, inf, 欠落など）【最重要】
```

---

## メソッドレベルのテスト網羅【最重要】

**原則**: 処理の最小単位は**メソッド/関数**であり、各メソッドに対して正常系・境界値・異常系を網羅する。

### なぜメソッドレベルか

- コンポーネントレベルでは異常系があっても、特定メソッドの異常系が漏れる可能性がある
- メソッドごとにテストがあれば、意図せぬ動作を防げる
- リファクタリング時の回帰テストとして機能する

### メソッドレベルテストのチェックリスト

各メソッドに対して以下を確認:

```
□ 正常系: 期待通りの入力で正しく動作するか？
□ 境界値: 引数の端の値で正しく動作するか？
□ 異常系: 不正入力でエラーが発生するか？
```

### 例: `select_forecast_day(day: int)` メソッド

```gherkin
# 正常系
Scenario: forecast_day=7で予測を抽出
  Given 有効な予測データがある
  When forecast_day=7で予測を抽出する
  Then PeriodForecastが返される

# 境界値
Scenario: forecast_day=1（最小値）で予測を抽出
  ...

Scenario: forecast_day=365（最大値）で予測を抽出
  ...

# 異常系（このメソッド固有のエラーケース）
Scenario: forecast_day=0でエラー
  When forecast_day=0で予測を抽出する
  Then ValueError が発生する

Scenario: forecast_day=-1でエラー
  When forecast_day=-1で予測を抽出する
  Then ValueError が発生する

Scenario: 存在しないforecast_dayカラムでエラー
  Given day1とday7のみの予測データがある
  When forecast_day=30で予測を抽出する
  Then ColumnNotFoundError が発生する
```

---

## 異常系テストの徹底【最重要】

**目的**: どのような入力でエラーが発生するかを明確にし、エラーハンドリングの網羅性を保証する。

### 異常系テストが重要な理由

1. **システムの堅牢性**: 不正入力に対する挙動を明確化
2. **エラーメッセージの品質**: ユーザーが問題を特定できるか確認
3. **エラー伝播の検証**: 例外がどこでキャッチされるか確認
4. **ドキュメント代わり**: テストがエラー条件の仕様書になる

### 異常系テスト必須項目

**全コンポーネントで以下を必ずテストすること:**

| カテゴリ | テスト内容 | エラー例 | 必須度 |
|---------|----------|---------|--------|
| **必須カラム欠落** | 必要なカラムが**全て**ないDataFrame | `ColumnNotFoundError` | **必須** |
| **必須引数欠落** | 必要な引数がNone/未指定 | `ValueError`, `TypeError` | **必須** |
| **無効なフォーマット** | 日付形式不正、型不一致 | `ValueError` | **必須** |
| **範囲外の値** | 0以下、上限超過、負値 | `ValueError` | 範囲制約時 |
| **存在しないリソース** | ファイル不存在、キー不存在 | `FileNotFoundError`, `KeyError` | 該当時 |
| **null/None値** | 必須フィールドがnull | `ValueError` or 特定動作 | **必須** |
| **inf/nan値** | 無限大・非数値 | `ValueError` or 特定動作 | 数値処理時 |

---

## カラム欠落テストの徹底【必須】

**原則**: 必須カラムが複数ある場合、**全カラムについて欠落テストを行う**。

### なぜ全カラムか

- 1カラムだけテストしても、他のカラム欠落時の挙動が保証されない
- 各カラムへのアクセスパスが異なる可能性がある
- 全カラムテストで網羅性を確保する

### 実装方法: pytest.mark.parametrize

```python
import pytest
from pytest_bdd import scenarios, given, when, then, parsers

scenarios("schemas/s_records.feature")

# 必須カラムを定義
REQUIRED_COLUMNS = ["sku_id", "date", "quantity", "product_code_id"]


@pytest.mark.parametrize("missing_column", REQUIRED_COLUMNS)
def test_missing_column_raises_error(missing_column: str) -> None:
    """各必須カラム欠落時にエラーが発生することを確認"""
    # missing_column以外のカラムでDataFrame作成
    columns = {col: [...] for col in REQUIRED_COLUMNS if col != missing_column}
    data = pl.DataFrame(columns).lazy()

    dto = SalesRecords(data=data)

    with pytest.raises(ColumnNotFoundError):
        # 欠落カラムにアクセスするとエラー
        _ = dto.data.select(pl.col(missing_column)).collect()
```

### 実装方法: Featureファイルでの列挙

```gherkin
# === 異常系: 必須カラム欠落 ===
# Note: 全必須カラムについてテストすること

Scenario Outline: <column>カラム欠落でエラー
  Given <column>カラムが欠落したデータがある
  When DTOを作成してcollectする
  Then ColumnNotFoundError が発生する

  Examples:
    | column              |
    | sku_id              |
    | date                |
    | quantity            |
    | product_code_id     |
```

### Step定義でのループ処理

```python
@given(parsers.parse("{column}カラムが欠落したデータがある"), target_fixture="context")
def step_given_missing_column(context: Context, column: str) -> Context:
    """指定カラムが欠落したデータを作成"""
    all_columns = {
        "sku_id": ["sku001"],
        "date": [date(2024, 1, 1)],
        "quantity": [10],
        "product_code_id": ["prod001"],
    }
    # 指定カラムを除外
    columns = {k: v for k, v in all_columns.items() if k != column}
    context.data = pl.DataFrame(columns).lazy()
    return context
```

### DTOごとのカラム欠落テスト必須項目

| DTO | 必須カラム | テスト数 |
|-----|----------|---------|
| SalesRecords | sku_id, date, quantity, product_code_id | 4件 |
| PeriodSales | sku_id, actual_quantity_cum | 2件 |
| CumulativeForecastWide | sku_id, base_date_later_day* | 2件 |
| SkuErrors | sku_id, error, smoothed_actual, is_top_20pct | 4件 |

### 異常系テストの書き方

```gherkin
# === 異常系 ===
# 注: どんな入力でどんなエラーが発生するかを明確に

Scenario: 必須カラム欠落でエラー
  Given sku_idカラムが欠落したデータがある
  When 処理を実行する
  Then ColumnNotFoundError が発生する
  And エラーメッセージに "sku_id" が含まれる

Scenario: 無効な日付形式でエラー
  Given base_date="invalid-date"である
  When Processorを作成する
  Then ValueError が発生する
  And エラーメッセージに "Invalid date format" が含まれる

Scenario: 範囲外の値でエラー
  Given forecast_day=0である
  When select_forecast_day()を呼ぶ
  Then ValueError が発生する
  And エラーメッセージに "must be between 1 and 365" が含まれる

Scenario: 存在しないカラム指定でエラー
  Given day=999の予測カラムが存在しない
  When select_forecast_day(999)を呼ぶ
  Then ColumnNotFoundError が発生する
```

### エラーメッセージの検証

異常系テストでは、エラーの種類だけでなく**メッセージ内容も検証**すること:

```python
@then(parsers.parse('エラーメッセージに "{text}" が含まれる'))
def step_then_error_message_contains(context: Context, text: str) -> None:
    assert context.error is not None
    assert text in str(context.error)
```

### LazyFrameのエラー検出

Polars LazyFrameを使用する場合、エラーは`collect()`時に発生する。
Whenステップで必ずcollectしてエラーを捕捉すること:

```python
@when("処理を実行する")
def step_when_process(context: Context) -> None:
    try:
        context.result = processor.process(context.data)
        # LazyFrameのエラーはcollect時に発生
        _ = context.result.data.collect()
    except Exception as e:
        context.error = e
```

---

### 正常系（Happy Path）【必須】

| カテゴリ | テスト内容 | 必須度 |
|---------|----------|--------|
| 基本作成 | 有効なデータでDTO作成 | **必須** |
| 基本処理 | 正常データでの処理結果確認 | **必須** |
| オプショナル | 省略可能フィールドの扱い | 該当時 |
| 複数データ | リスト・バッチ処理 | 該当時 |

### 境界値（Boundary）【必須】

| カテゴリ | テスト内容 | 必須度 |
|---------|----------|--------|
| 空データ (n=0) | 空入力での動作確認 | **必須** |
| 単一データ (n=1) | 1件データでの動作確認 | **必須** |
| ゼロ値 | 0での動作確認 | 数値処理時 |
| 最小値 | 下限値での動作確認 | 範囲制約時 |
| 最大値 | 上限値での動作確認 | 範囲制約時 |

### 異常系（Error Cases）【必須】

| カテゴリ | テスト内容 | 必須度 |
|---------|----------|--------|
| 必須カラム欠落 | カラム欠落時のエラー | **必須** |
| null値 | null含むデータの挙動 | **必須** |
| 無効値 | inf, nan, 負値の挙動 | 数値処理時 |
| 型間違い | 期待と異なる型 | 該当時 |
| 範囲外 | 許容範囲外の値 | 範囲制約時 |

### 数値・行列系

| カテゴリ | テスト内容 |
|---------|----------|
| スカラー境界 | 0, 1, 1e10, inf, -inf, nan |
| ベクトル | 空, 長さ不一致, ゼロベクトル |
| 行列 | 形状(0,n), (n,0), 行数不一致 |
| 数値精度 | pytest.approx, 非負制約 |

### 日付系

| カテゴリ | テスト内容 |
|---------|----------|
| 年境界 | 12/31→1/1, 週番号の切り替え |
| 月境界 | 月末→月初, 月初フラグ |
| 特殊日 | うるう年2/29, 祝日 |
| 曜日・週 | isoweekday, 週開始日truncate |

```gherkin
# 異常系の例
Scenario Outline: 無効な数量でエラー
  Given 数量が <value> の販売データがある
  When SalesRecordを作成する
  Then ValueError が発生する

  Examples:
    | value   |
    | null    |
    | -1      |
    | inf     |
    | nan     |
```

## コンポーネント別テスト指針【3カテゴリ必須】

**全コンポーネントで正常系・境界値・異常系を必ず実装すること。**

| 対象 | 正常系 | 境界値 | 異常系 |
|------|--------|--------|--------|
| DTO | 作成・プロパティ | 空データ, n=1 | null/inf/nan/カラム欠落 |
| Processor | 変換の正確性 | 空入力, n=1, ゼロ値 | **DTO未担保の異常系のみ** |
| Calculator | 計算結果確認 | 空データ, n=1, ゼロ値 | 空データでNaN返却 |
| Transformer | fit/transform整合性 | 空データ, n=1 | 未fitでtransform |
| Model | fit/predict動作 | 空データ, n=1 | 未fitでpredict |
| Pipeline | E2E処理 | 空入力, 最小データ | 途中エラーの伝播 |

### 異常系テストの責務分担【重要】

**原則**: DTOでバリデーションされるエラー条件は、DTOテストで網羅すればよい。Processorで重複テストは不要。

```
DTOで担保されるエラー → DTOテストのみ（Processor側で重複不要）
Processor固有のエラー → Processorテストで実装
```

#### DTOで担保される異常系（Processorテスト不要）

以下のエラー条件はDTOのバリデーションでカバーされるため、Processorテストでは省略可能:

| エラー条件 | DTOで担保 | Processorテスト |
|-----------|----------|----------------|
| 必須カラム欠落 | DTO.model_validator | **省略可** |
| カラム型不一致 | DTO.SCHEMA | **省略可** |
| 必須フィールドnull | DTO.model_validator | **省略可** |

#### Processor固有の異常系（テスト必須）

以下のエラー条件はDTOでは担保されず、Processorテストで実装が必要:

| エラー条件 | 例 | テスト必須 |
|-----------|---|----------|
| Processor引数の不正 | `outlier_percentile=-0.1` | **必須** |
| 処理条件の不正 | `forecast_day=0` | **必須** |
| 処理ロジック固有のエラー | データなしでquantile計算 | **必須** |

#### 判断フローチャート

```
異常系テストを書く際の判断:
1. このエラーはDTOのバリデーションで発生するか？
   → Yes: DTOテストで網羅済みならProcessorテスト省略可
   → No: Processorテストで実装必須

2. Processorが追加のバリデーションをするか？
   → Yes: そのバリデーションをテスト
   → No: DTOテストに委譲
```

#### 例: ForecastActualJoiner

```python
# ForecastActualJoinerが受け取るDTO
# - PeriodForecast: sku_id, predicted_quantity
# - PeriodSales: sku_id, actual_quantity_cum

# DTOで担保される異常系（Joinerテスト不要）:
# - sku_id欠落 → PeriodForecast/PeriodSalesのテストで網羅
# - predicted_quantity欠落 → PeriodForecastのテストで網羅

# Joiner固有の異常系（テスト必須）:
# - なし（Joinerは単純なleft joinのみ）
```

### Processor必須テスト一覧

```gherkin
# 正常系（必須）
Scenario: 正常データで処理
  Given 有効なデータがある
  When 処理を実行する
  Then 結果が正しい

# 境界値（必須）
Scenario: 空データで処理
  Given 空のデータがある
  When 処理を実行する
  Then 空の結果が返る（またはエラー）

Scenario: 1件のみで処理
  Given 1件のデータがある
  When 処理を実行する
  Then 結果が正しい

# 異常系（必須）
Scenario: 必須カラム欠落でエラー
  Given 必須カラムが欠落したデータがある
  When 処理を実行する
  Then ColumnNotFoundError が発生する
```

## 詳細リファレンス

- **パターン集**: [references/patterns.md](references/patterns.md)

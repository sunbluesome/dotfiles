---
title: データスキーマ知識ベース
keywords:
  - DTO
  - スキーマ
  - カラム
  - 型
  - ForecastWide
  - ForecastLong
  - SalesRecords
  - AccuracyMetrics
  - PeriodSalesAggregatedRecords
  - ForecastActualRecords
  - Pydantic
  - LazyFrame
  - パーティション
  - Hive
topics:
  - 予測データ構造
  - 実績データ構造
  - 精度指標出力
  - 中間DTO
updated: 2026-01-07
---

# データスキーマ知識ベース

プロジェクトで使用するDTOの定義、カラム仕様、型制約を記録。

---

## ForecastWide

### 概要
予測値DTO（Wide形式365カラム）。Hiveパーティション構造で格納。

### パーティション構造
```
base_date={YYYY-MM-DD}/seller_id={uuid}/
```

### カラム定義
| カラム名 | 型 | 説明 | 制約 |
|----------|-----|------|------|
| sku_id | String | SKU ID | 必須 |
| seller_id | String | 店舗ID（パーティション） | 必須 |
| base_date_later_day1〜365 | Float64 | 累計販売予測数 | または日付形式 |
| YYYY-MM-DD形式 | Float64 | リネーム後の形式 | または元形式 |

### バリデーションルール
- 予測カラムは元形式（base_date_later_dayN）または日付形式（YYYY-MM-DD）のいずれか
- 予測カラム数は365以下

### 使用箇所
- `ForecastColumnRenamer`: カラム名リネーム
- `ForecastToLongConverter`: Wide→Long変換

---

## ForecastLong

### 概要
予測値DTO（Long形式）。Wide形式から変換後の構造。

### カラム定義
| カラム名 | 型 | 説明 | 制約 |
|----------|-----|------|------|
| sku_id | String | SKU ID | 必須 |
| seller_id | String | 店舗ID | 必須 |
| base_date | Date | 予測基準日 | 必須 |
| forecast_day | Int32 | 予測対象日数（1-365） | 必須 |
| target_date | Date | 予測対象日 | base_date + forecast_day |
| predicted_quantity | Float64 | 予測数量 | 必須 |

### 使用箇所
- `PeriodSalesAggregator`: 期間集計の基準
- `ForecastActualJoiner`: 予測・実績結合

---

## SalesRecords

### 概要
実績販売データDTO。日別のSKU×店舗の販売数量。

### カラム定義
| カラム名 | 型 | 説明 | 制約 |
|----------|-----|------|------|
| sku_id | String | SKU ID | 必須 |
| date | Date | 販売日 | 必須 |
| quantity | Float64 | 販売数量 | 正の値 |

### バリデーションルール
- quantity > 0（SalesCleanerで0以下を除去）
- NaN/Infは除去対象

### 使用箇所
- `SalesCleaner`: 不正値除去
- `PeriodSalesAggregator`: 期間集計

---

## AccuracyMetrics

### 概要
精度指標DTO（フラット構造）。店舗×forecast_day×セグメント単位の精度。

### カラム定義
| カラム名 | 型 | 説明 | 制約 |
|----------|-----|------|------|
| date | String | 基準日（YYYY-MM-DD） | 必須 |
| forecast_day | Int32 | 予測対象日数 | 1-365 |
| segment | String | セグメント | "all" or "top_20pct" |
| wmape | Float64 | 加重平均絶対誤差率 | 比率（0〜∞） |
| bias_pct | Float64 | 系統的偏り（平均） | 比率（-∞〜∞） |
| bias_pct_median | Float64 | 系統的偏り（中央値） | 比率（-∞〜∞） |
| mare_mean | Float64 | SKU相対誤差平均 | 比率（0〜∞） |
| mare_median | Float64 | SKU相対誤差中央値 | 比率（0〜∞） |

### セグメント定義
- `all`: 全SKU
- `top_20pct`: 販売数上位20%のSKU

### 使用箇所
- `AccuracyCalculator`: 精度計算出力
- `entrypoint.py`: 結果保存

---

## PeriodSalesAggregatedRecords

### 概要
期間集計済み実績DTO（内部用）。予測期間に対応する実績累計。

### カラム定義
| カラム名 | 型 | 説明 | 制約 |
|----------|-----|------|------|
| sku_id | String | SKU ID | 必須 |
| forecast_day | Int32 | 予測対象日数 | 必須 |
| actual_quantity_cum | Float64 | 期間内実績累計 | 0以上 |

### 使用箇所
- `PeriodSalesAggregator`: 出力
- `ForecastActualJoiner`: 入力

---

## ForecastActualRecords

### 概要
予測・実績結合済みDTO。精度計算の入力。

### カラム定義
| カラム名 | 型 | 説明 | 制約 |
|----------|-----|------|------|
| sku_id | String | SKU ID | 必須 |
| seller_id | String | 店舗ID | 必須 |
| base_date | Date | 予測基準日 | 必須 |
| forecast_day | Int32 | 予測対象日数 | 必須 |
| target_date | Date | 予測対象日 | 必須 |
| predicted_quantity | Float64 | 予測数量 | 必須 |
| actual_quantity_cum | Float64 | 期間内実績累計 | 0以上（null→0埋め） |

### 使用箇所
- `ForecastActualJoiner`: 出力
- `AccuracyCalculator`: 入力

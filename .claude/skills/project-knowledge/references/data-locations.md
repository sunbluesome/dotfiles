---
title: 実データ配置知識ベース
keywords:
  - データ配置
  - data/interim
  - パス
  - 予測データ
  - 実績データ
  - goya_prediction
  - ml_ts_dataset
  - aandf
  - edwinejdb2
  - tabio
  - クライアント
  - Hive
  - Parquet
  - 1-feat-implement-wmape
topics:
  - 実データディレクトリ構造
  - クライアント別パス
  - 予測データパス
  - 実績データパス
  - Hiveパーティション
updated: 2026-01-07
---

# 実データ配置知識ベース

開発・検証用の実データ配置場所を記録。

---

## ベースディレクトリ

```
data/interim/1-feat-implement-wmape/
```

ブランチ名に対応したディレクトリ配下にデータを配置。

---

## クライアント一覧

| クライアント | コード名 | 店舗数 | 基準日数 | 備考 |
|-------------|---------|--------|---------|------|
| エイアンドエフ | `aandf` | 33店舗 | 少数 | 中規模 |
| エドウィン（アウトレット） | `edwinejdb2` | 27店舗 | 少数 | 小規模テスト向け |
| タビオ | `tabio` | 99店舗 | 91日分 | 大規模・時系列分析向け |

---

## 予測データ（ForecastWide）

### パス構造

```
data/interim/1-feat-implement-wmape/v3.{domain}.{client}/stored/goya_prediction/base_date={YYYY-MM-DD}/seller_id={uuid}/
```

### 具体例

| クライアント | ドメイン | パス |
|-------------|---------|------|
| aandf | `v3.jp.co` | `.../v3.jp.co.aandf/stored/goya_prediction/base_date=2025-11-25/seller_id={uuid}/` |
| edwinejdb2 | `v3.jp.co` | `.../v3.jp.co.edwinejdb2/stored/goya_prediction/base_date=2025-11-25/seller_id={uuid}/` |
| tabio | `v3.com` | `.../v3.com.tabio/stored/goya_prediction/base_date=2025-10-08/seller_id={uuid}/` |

### 利用可能な基準日

| クライアント | 基準日範囲 |
|-------------|-----------|
| aandf | `2025-11-25` |
| edwinejdb2 | `2025-11-25`, `2025-12-02` |
| tabio | `2025-10-08` 〜 `2026-01-06`（91日分） |

### ファイル形式

- **形式**: Parquet
- **ファイル名**: `00000000.parquet`
- **パーティション**: Hive形式（base_date, seller_id）

---

## 実績データ（SalesRecords）

### パス構造

```
data/interim/1-feat-implement-wmape/v3.sagemaker.prod/{client}/short_term_predict/estimate/{YYYY-MM-DD}/input/ml_ts_dataset/seller_id={uuid}/
```

### 具体例

| クライアント | パス |
|-------------|------|
| aandf | `.../v3.sagemaker.prod/aandf/short_term_predict/estimate/2026-01-04/input/ml_ts_dataset/seller_id={uuid}/` |
| edwinejdb2 | `.../v3.sagemaker.prod/edwinejdb2/short_term_predict/estimate/2026-01-04/input/ml_ts_dataset/seller_id={uuid}/` |
| tabio | `.../v3.sagemaker.prod/tabio/short_term_predict/estimate/{date}/input/ml_ts_dataset/seller_id={uuid}/` |

### ファイル形式

- **形式**: Parquet
- **ファイル名**: `000.parquet`
- **パーティション**: Hive形式（seller_id）

---

## データ読み込みパターン

### Polarsでの読み込み例

```python
import polars as pl

BASE_DIR = "data/interim/1-feat-implement-wmape"

# 予測データ（全店舗一括）
forecast_path = f"{BASE_DIR}/v3.jp.co.aandf/stored/goya_prediction/"
forecast_df = pl.scan_parquet(f"{forecast_path}/**/*.parquet", hive_partitioning=True)

# 実績データ（全店舗一括）
sales_path = f"{BASE_DIR}/v3.sagemaker.prod/aandf/short_term_predict/estimate/2026-01-04/input/ml_ts_dataset/"
sales_df = pl.scan_parquet(f"{sales_path}/**/*.parquet", hive_partitioning=True)
```

### 特定店舗のみ

```python
seller_id = "71e10d67-617d-5807-b8fd-33fcca2f5f9c"
base_date = "2025-11-25"

# 特定店舗の予測データ
forecast_seller = pl.scan_parquet(
    f"{BASE_DIR}/v3.jp.co.aandf/stored/goya_prediction/base_date={base_date}/seller_id={seller_id}/*.parquet"
)
```

---

## 注意点

### seller_idの一致

- 予測データと実績データで同じ`seller_id`を使用
- ただし、クライアントが異なると`seller_id`も異なる

### 日付の扱い

- 予測データの`base_date`: 予測作成日
- 実績データのパス日付: データ取得日（必ずしも`base_date`と一致しない）

### データ量

- 1店舗あたり数百〜数千SKU
- 全店舗で数万レコード

---

## 検証用データセット

### 動作確認に推奨

| 目的 | クライアント | 理由 |
|------|-------------|------|
| 小規模テスト | edwinejdb2 | 店舗数が少ない（27店舗） |
| 中規模テスト | aandf | 店舗数が中程度（33店舗） |
| 大規模・時系列分析 | tabio | 99店舗×91日分、長期傾向分析向け |

### サンプル店舗ID

- **aandf**: `71e10d67-617d-5807-b8fd-33fcca2f5f9c`
- **edwinejdb2**: `a2ded3ff-d89a-5ce9-b3b8-9907b54bdcd9`
- **tabio**: `06290100-19da-56df-b4bc-56c1437e5f71`

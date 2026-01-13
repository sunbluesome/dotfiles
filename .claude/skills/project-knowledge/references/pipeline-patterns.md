---
title: パイプラインパターン知識ベース
keywords:
  - Processor
  - Pipeline
  - IProcessor
  - データフロー
  - オーケストレーション
  - DI
  - Constructor Injection
  - Stateless
  - 単一責任
  - SRP
  - entrypoint
  - 並列処理
  - ProcessPoolExecutor
  - Click
  - CLI
topics:
  - Processor設計パターン
  - 責務分離
  - データフロー設計
  - Pipeline設計
  - entrypoint実装
  - アンチパターン
updated: 2026-01-07
---

# パイプラインパターン知識ベース

Processor設計、データフロー、オーケストレーションのパターンを記録。

---

## Processorパターン

### 基本原則

1. **Stateless**: Processorは状態を持たない
2. **単一責任**: 1 Processor = 1 責務
3. **IProcessor継承**: `IProcessor[TInput, TOutput]` を実装
4. **純粋関数**: 同じ入力に対して常に同じ出力

### 実装テンプレート

```python
from interface.i_processor import IProcessor
from schemas.s_input import InputDTO
from schemas.s_output import OutputDTO

class MyProcessor(IProcessor[InputDTO, OutputDTO]):
    """単一責任の説明

    処理内容:
    1. ステップ1
    2. ステップ2
    """

    def __init__(self, param: str):
        """初期化時に必要なパラメータを受け取る"""
        self._param = param

    def process(self, data: InputDTO) -> OutputDTO:
        """処理実行"""
        # 処理ロジック
        return OutputDTO(data=result)
```

---

## 責務分離パターン

### パターン: 集計と結合の分離

**背景**: 集計処理と結合処理を1つのProcessorで行うとテストが困難

**解決策**: 2つのProcessorに分離

```
Before: PeriodAccuracyMatcher（集計 + 結合）
After:  PeriodSalesAggregator（集計のみ）
        ForecastActualJoiner（結合のみ）
```

**利点**:
- 各Processorのテストが容易
- 責務が明確
- 再利用性が向上

### パターン: 変換と計算の分離

**背景**: 形式変換と計算を同時に行うと複雑化

**解決策**: 変換 → 計算の2段階

```
ForecastColumnRenamer（カラム名変換: ForecastWide → ForecastRenamed）
  ↓
ForecastToLongConverter（形式変換: ForecastRenamed → ForecastLong）
  ↓
IntermediateMetricsCalculator（中間データ計算）
```

### パターン: 動的スキーマDTOの分割

**背景**: カラム名が変換前後で異なる場合、1つのDTOで両方を表現すると暗黙的な依存関係が生まれる

**問題のあるコード**:
```python
# Bad: hasattrで条件分岐 → DTOの構造に暗黙的に依存
if hasattr(self._record_type, "get_full_schema"):
    schema = self._record_type.get_full_schema()
elif hasattr(self._record_type, "SCHEMA"):
    schema = self._record_type.SCHEMA
```

**解決策**: 変換前後で別のDTOを定義

```python
# Good: 明示的な型定義
class ForecastWide:
    """元形式（base_date_later_day1〜365）"""
    SCHEMA = _generate_forecast_schema()  # 固定スキーマ

class ForecastRenamed:
    """リネーム後（YYYY-MM-DD形式カラム）"""
    # スキーマは動的のためSCHEMA未定義（ParquetLoaderでは読み込まない）
```

**利点**:
- 入力型と出力型が明示的
- `hasattr`による条件分岐が不要
- テストが容易

---

## データフローパターン

### 精度評価パイプライン

```
ForecastWide ──→ ForecastColumnRenamer ──→ ForecastRenamed
                        ↓
SalesRecords ──→ SalesCleaner ──────────→ SalesRecords(cleaned)
                        ↓
              ForecastToLongConverter ──→ ForecastLong
                        ↓
              PeriodSalesAggregator ────→ PeriodSalesAggregatedRecords
                        ↓
              ForecastActualJoiner ─────→ ForecastActualRecords
                        ↓
          IntermediateMetricsCalculator ─→ StoreIntermediateMetrics, SkuRelativeErrors
                        ↓
         (entrypoint) GlobalMetricsAggregator ─→ AccuracyMetrics (global)
                      StoreMetricsAggregator ──→ AccuracyMetrics (store)
```

### 結合パターン

| 結合タイプ | 用途 | 例 |
|-----------|------|-----|
| inner join | 両方に存在するデータのみ | SKU×日付の集計 |
| left join + fill_null | 左側全件保持、右側なしは0埋め | 予測+実績結合 |

---

## Pipeline設計パターン

### Constructor Injection

```python
class AccuracyEvaluationPipeline:
    def __init__(
        self,
        sales_cleaner: SalesCleaner,
        renamer: ForecastColumnRenamer,
        converter: ForecastToLongConverter,
        aggregator: PeriodSalesAggregator,
        joiner: ForecastActualJoiner,
    ):
        self._sales_cleaner = sales_cleaner
        self._renamer = renamer
        ...
```

**利点**:
- テスト時にモックを注入可能
- 依存関係が明示的
- 設定の柔軟性

### Step Method パターン

```python
def evaluate(self, forecast, sales, forecast_day):
    # Step 1
    renamed = self._step_rename_columns(forecast)
    # Step 2
    long_format = self._step_wide_to_long(renamed)
    # ...
```

**利点**:
- 各ステップが明確
- デバッグが容易
- テスト可能なポイントが明確

---

## entrypointパターン

### 並列処理パターン

```python
def _evaluate_worker(seller_id, forecast_day, forecast_all, sales_all, base_date):
    """店舗×forecast_day単位のワーカー"""
    # フィルタ
    forecast_seller = ForecastWide(
        data=forecast_all.data.filter(pl.col("seller_id") == seller_id)
    )
    # パイプライン実行
    pipeline = AccuracyEvaluationPipeline(...)
    return pipeline.evaluate(...)
```

**パターン**:
1. データを一括ロード
2. ワーカー関数で店舗単位にフィルタ
3. ProcessPoolExecutorで並列実行
4. 結果を集約

### CLIパターン（Click）

```python
@cli.group()
def local():
    """Run locally with explicit paths."""
    pass

@local.command("evaluate")
@common_options
@local_path_options
def local_evaluate(...):
    ...
```

**パターン**:
- グループ（local, sagemaker）で環境を分離
- 共通オプションをデコレータで再利用
- 環境固有の設定はグループ内で固定

---

## アンチパターン

### 避けるべき: 1 Processorで複数責務

```python
# Bad
class DataProcessor:
    def process(self, data):
        # クリーニング
        # 変換
        # 計算
        # 保存
```

### 避けるべき: Processor内でのI/O

```python
# Bad
class MyProcessor:
    def process(self, data):
        df = pl.read_parquet("data.parquet")  # I/O禁止
        ...
```

### 避けるべき: 未使用パラメータ

```python
# Bad
def __init__(self, lookback_weeks: int = 4):  # 使っていない
    self._lookback_weeks = lookback_weeks
```

→ YAGNIに従い削除

### 避けるべき: 暗黙的な依存関係（hasattr/getattr条件分岐）

```python
# Bad: DTOの構造を知っている前提のコード
if hasattr(self._record_type, "get_full_schema"):
    schema = self._record_type.get_full_schema()
elif hasattr(self._record_type, "SCHEMA"):
    schema = getattr(self._record_type, "SCHEMA")
```

→ DTOを分割して明示的な型を使用

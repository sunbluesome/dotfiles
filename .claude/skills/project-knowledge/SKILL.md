---
name: project-knowledge
description: |
  This skill should be used when implementing new features, understanding existing patterns, or when the user asks about "project-specific knowledge", "domain knowledge", "business logic", "data schema", "pipeline patterns", "WMAPE", "Bias", "Processor". Also used when the user says "document this pattern", "add to knowledge base", or when recurring patterns are identified. MUST reference before implementing features to ensure consistency with existing patterns.
version: 0.3.0
---

# Project Knowledge Base

プロジェクト固有のドメイン知識、データスキーマ、パイプラインパターン、ビジネスロジックを蓄積・参照するスキル。

## 目的

1. **知識の蓄積**: 実装中に発見したパターン・制約・ベストプラクティスを記録
2. **知識の参照**: 新機能実装前に既存パターンを確認し、一貫性を保つ
3. **暗黙知の形式化**: コードレビューで発見した暗黙のルールを明文化

## 索引検索（コンテキスト節約）

各referenceファイルはYAML frontmatterにkeywordsとtopicsを持つ。
キーワード検索で関連ファイルを特定し、必要なファイルのみ読み込む。

### 索引一覧

| ファイル | keywords | topics |
|---------|----------|--------|
| `data-schemas.md` | DTO, スキーマ, ForecastWide, ForecastLong, SalesRecords, AccuracyMetrics, Pydantic, LazyFrame, パーティション | 予測/実績データ構造, 精度指標出力, 中間DTO |
| `accuracy-metrics.md` | WMAPE, Bias, MARE, 精度, 誤差, bias_pct, bias_pct_median, セグメント, top_20pct, 外れ値 | 精度指標定義, 計算式, 指標解釈, 外れ値対応 |
| `pipeline-patterns.md` | Processor, Pipeline, IProcessor, DI, Constructor Injection, Stateless, SRP, entrypoint, 並列処理 | Processor設計, 責務分離, データフロー, アンチパターン |
| `data-characteristics.md` | データ特性, 外れ値, スパース, SKUマッチング, ロングテール, クリーニング | 予測/実績データ特性, 外れ値パターン, 品質チェック |
| `data-locations.md` | データ配置, data/interim, パス, goya_prediction, ml_ts_dataset, aandf, edwinejdb2, tabio, クライアント, Hive, Parquet | 実データディレクトリ構造, クライアント別パス, Hiveパーティション |

### 検索フロー

```
1. ユーザーの質問/タスクからキーワード抽出
2. 上記索引でマッチするファイルを特定
3. 関連ファイルのみ読み込み
4. 必要な知識を適用
```

### 検索例

| 質問/タスク | マッチキーワード | 参照ファイル |
|------------|-----------------|-------------|
| 「WMAPEの計算方法」 | WMAPE, 精度 | `accuracy-metrics.md` |
| 「Processorの設計」 | Processor, IProcessor | `pipeline-patterns.md` |
| 「ForecastWideの構造」 | ForecastWide, DTO | `data-schemas.md` |
| 「外れ値の扱い」 | 外れ値 | `accuracy-metrics.md`, `data-characteristics.md` |
| 「実データはどこ」 | data/interim, パス | `data-locations.md` |
| 「aandfのデータ」 | aandf, クライアント | `data-locations.md` |

## 知識カテゴリ

| カテゴリ | 格納先 | 内容 |
|---------|--------|------|
| データスキーマ | `references/data-schemas.md` | DTO構造、カラム定義、型制約 |
| パイプラインパターン | `references/pipeline-patterns.md` | 処理フロー、Processor設計 |
| 精度指標 | `references/accuracy-metrics.md` | WMAPE, Bias%, MAREの定義と解釈 |
| データ特性 | `references/data-characteristics.md` | データの特徴、外れ値、制約 |
| 実データ配置 | `references/data-locations.md` | 実データのパス、クライアント情報 |

## 知識参照フロー

### 新機能実装前（必須）

1. 索引検索で関連referenceを特定
2. 既存パターンに従った実装を検討
3. 既存パターンがない場合は新規パターンとして記録

### 実装後

1. 新たなパターン・知見があれば該当referenceに追記
2. YAML frontmatterのkeywordsも更新

## 矛盾・競合の検出と解決

### 検出すべき矛盾パターン

| パターン | 例 | 対応 |
|---------|-----|------|
| **定義の矛盾** | 既存: 「Bias%は平均」 vs 新規: 「Bias%は中央値」 | ユーザーに確認 |
| **パターンの競合** | 既存: 「inner join」 vs 新規: 「left join」 | 使い分け条件を明確化 |
| **制約の変更** | 既存: 「quantity > 0」 vs 新規: 「quantity >= 0」 | 影響範囲を提示して確認 |
| **廃止・置換** | 既存パターンが非推奨に | 既存知識の更新を提案 |

### 矛盾検出時のフロー

```
1. 矛盾を検出
2. 既存知識と新規情報を明示
3. 以下の選択肢を提示:
   a) 既存知識を維持（新規を破棄）
   b) 新規情報で上書き（既存を更新）
   c) 両方を併記（条件付きで使い分け）
   d) 統合（より正確な定義に修正）
   e) other (ユーザーに説明を求める)
4. ユーザーの決定に従い更新
```

### 質問テンプレート

```markdown
## 知識の矛盾を検出しました

### 既存の知識（{ファイル名}）
{既存の内容}

### 新規の情報
{新しい内容}

### 矛盾点
{何が矛盾しているか}

### 提案
以下のいずれかを選択してください:
1. **既存維持**: {既存を維持する理由}
2. **新規採用**: {新規を採用する理由}（推奨: {理由があれば}）
3. **条件付き併記**: {使い分け条件の案}
4. **統合案**: {統合した場合の定義}
```

### 矛盾解決後

1. 選択された方針に従いreferenceを更新
2. 更新履歴として変更理由を記録（該当セクションのコメントまたは末尾に追記）
3. `updated`日付を更新

## 知識記録フォーマット

### パターン記録

```markdown
## {パターン名}

### 概要
{1-2文でパターンの目的を説明}

### 適用条件
- {このパターンを使用すべき状況}

### 実装例
{コード例}

### 注意点
- {実装時の注意点}
```

### 新規referenceファイル作成時

必ずYAML frontmatterを含める:

```markdown
---
title: {タイトル}
keywords:
  - {検索キーワード1}
  - {検索キーワード2}
topics:
  - {トピック1}
  - {トピック2}
updated: {YYYY-MM-DD}
---

# {タイトル}
...
```

## 知識の更新タイミング

### 自動的に記録すべき場面

1. **新しいDTO作成時**: `data-schemas.md` に追加
2. **新しいProcessorパターン発見時**: `pipeline-patterns.md` に追加
3. **精度指標の解釈が明確化された時**: `accuracy-metrics.md` に追加
4. **データの特性が判明した時**: `data-characteristics.md` に追加

### frontmatter更新

知識追加時は該当ファイルのYAML frontmatterも更新:
- `keywords`: 新しい検索キーワードを追加
- `updated`: 更新日を更新

## 参照ファイル

- **`references/data-schemas.md`** - DTO定義、カラム仕様、型制約
- **`references/pipeline-patterns.md`** - Processor設計、データフロー
- **`references/accuracy-metrics.md`** - WMAPE, Bias%, MAREの定義と解釈
- **`references/data-characteristics.md`** - データの特徴、外れ値、制約
- **`references/data-locations.md`** - 実データのパス、クライアント別構造

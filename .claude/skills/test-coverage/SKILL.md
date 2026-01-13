---
name: test-coverage
description: |
  This skill should be used when the user asks to "テストのドキュメントを作成", "create test document", "テストをレビュー", "review tests", "テスト網羅性を確認", "test coverage", "テストマトリクスを作成", "テストが十分か確認", "必要なテストを洗い出し", "テスト設計", "テストケース一覧", "missing tests", "テストの漏れがないか", "what tests are needed". (project)
---

# テスト網羅性確認スキル

AIエージェントが作成したテストの**妥当性・網羅性を人間が素早く判断**するためのドキュメントを生成する。

**特徴**: 処理フロー図に沿ってテストを整理し、「どの処理にどんなテストがあるか」を可視化する。

## 目的

1. **実装前**: 必要なテストケースを体系的に洗い出す
2. **実装後**: 既存テストが十分かを確認する

## 出力ファイル

```
_docs/test-coverage/{issue-name}/YYYYMMDDHHMM.md
```

NOTE: The issue name can be obtained from the branch name. Branch names are like {layer}/{issue-name} or {issue-name}.

## ワークフロー

### 実装前（テスト設計）

1. 対象機能のコードまたはprocessing-flow-docを読み込む
2. 処理フロー図を作成・参照
3. 各ステップのテストマトリクスを生成
4. マトリクスをレビュー用ドキュメントとして出力

### 実装後（テスト検証）

1. 対象機能のコードとテストを読み込む
2. processing-flow-docがあれば参照
3. 処理フロー図にテストカバレッジをマッピング
4. カバレッジステータス付きドキュメントを出力

---

## ドキュメント構造【重要】

### 1. サマリー

```markdown
## テスト網羅性サマリー

| 項目 | 値 |
|------|-----|
| 対象 | `src/processor/foo.py` |
| テスト | `tests/src/processor/test_foo.py` |
| カバー率 | 12/15 (80%) |
| 未カバー | 境界値: 2件, 異常系: 1件 |
```

### 2. 処理フロー × テストマトリクス【核心】

**処理フロー図の各ブロックに対応するテストを可視化する。**

```markdown
## 処理フロー × テストカバレッジ

### 全体フロー

\```mermaid
flowchart TB
    P1["Step 1: 入力処理<br/>✓ 3/3"]
    P2["Step 2: データ変換<br/>✓ 4/4"]
    P3["Step 3: 計算処理<br/>⚠ 2/4"]
    P4["Step 4: 出力処理<br/>✓ 2/2"]

    P1 --> P2 --> P3 --> P4

    style P1 fill:#c8e6c9,stroke:#388e3c
    style P2 fill:#c8e6c9,stroke:#388e3c
    style P3 fill:#fff9c4,stroke:#f57c00,stroke-width:2px
    style P4 fill:#c8e6c9,stroke:#388e3c
\```

**凡例**:
- 🟢 緑: 全テストカバー (100%)
- 🟡 黄: 一部未カバー（要確認）
- 🔴 赤: Critical未カバー
```

#### フロー図の表示ルール

- **シンプルに**: ステップ名 + カバレッジ数のみ（例: `✓ 3/3`, `⚠ 2/4`）
- **詳細はマトリクスで**: テスト内容の説明はテストマトリクスの「説明」カラムに記載
- **色で状態を示す**: 緑=全カバー、黄=一部未カバー、赤=Critical未カバー

### 3. ステップ別テストマトリクス

```markdown
### Step 3: 計算処理 ⚠ 2/4

**コンテキスト図**:
\```mermaid
flowchart TB
    P1["Step 1: 入力処理"] --> P2["Step 2: データ変換"] --> P3["Step 3: 計算処理"] --> P4["Step 4: 出力処理"]
    style P3 fill:#ffeb3b,stroke:#f57c00,stroke-width:4px
\```

**対象コンポーネント**:
- `WmapeCalculator` - WMAPE計算
- `BiasPctCalculator` - Bias%計算

**テストマトリクス**:

| # | コンポーネント | メソッド | テストケース | 説明 | カテゴリ | エラー処理 | カバー |
|---|---------------|---------|-------------|------|---------|-----------|--------|
| 1 | WmapeCalculator | [`calculate()`](../../../src/processor/wmape_calculator.py#L15) | [正常計算](../../../tests/src/processor/test_wmape.py#L10) | 複数SKUの誤差データからWMAPE（加重平均絶対誤差率）を計算する | 正常系 | - | ✓ |
| 2 | WmapeCalculator | [`calculate()`](../../../src/processor/wmape_calculator.py#L15) | [空→NaN](../../../tests/src/processor/test_wmape.py#L25) | SKUが0件の場合、除算不可のためNaNを返す | 境界値 | NaN返却（呼び出し元で判定） | ✓ |
| 3 | WmapeCalculator | [`calculate()`](../../../src/processor/wmape_calculator.py#L15) | n=1 ← **未カバー** | SKUが1件のみの場合の計算（統計量の特殊ケース） | 境界値 | - | ✗ |
| 4 | ParquetLoader | [`load()`](../../../src/data_io/parquet_loader.py#L20) | [ファイル不存在](../../../tests/src/data_io/test_parquet_loader.py#L30) | 存在しないパスでエラー発生 | 異常系 | FileNotFoundError→Pipeline→CLI | ✓ |
| 5 | CumulativeForecastWide | [`__init__()`](../../../src/schemas/s_forecast.py#L17) | [sku_id欠落](../../../tests/src/schemas/test_s_forecast.py#L45) | 必須カラム欠落時にエラー発生 | 異常系 | ValidationError→Pipeline→CLI | ✓ |

**未カバー項目**:
- ✗ n=1: 標準偏差計算で特殊ケース
```

#### テストマトリクスのカラム定義

| カラム | 説明 | 例 |
|--------|------|-----|
| コンポーネント | テスト対象のクラス/モジュール名 | `WmapeCalculator`, `ParquetLoader` |
| メソッド | テスト対象のメソッド名（括弧付き、必ずバッククォートで囲む）。**リンク形式**で記載 | [`calculate()`](src/processor/wmape_calculator.py#L15) |
| テストケース | テストの短い名前（Scenarioタイトル相当）。**テストファイルへのリンク**で記載 | [正常計算](tests/src/processor/test_wmape.py#L10) |
| 説明 | 何を確認し、なぜ重要かの自然言語説明 | SKUが0件の場合、除算不可のためNaNを返す |
| カテゴリ | 正常系/境界値/異常系/ビジネス | 正常系, 境界値, 異常系 |
| エラー処理 | エラーがどこでキャッチされ、どう連鎖するか | `ValueError→Pipeline→CLI` |
| カバー | テスト有無 | ✓ / ✗ |

#### リンクの書き方【必須】

**重要**: リンクはドキュメントファイルからの**相対パス**で記載すること。

ドキュメント配置例: `_docs/test-coverage/{issue-name}/YYYYMMDDHHMM.md`

**メソッド名**: ソースファイルの該当行へのリンク（相対パス）

```markdown
[`calculate()`](../../../src/processor/wmape_calculator.py#L15)
```

**テストケース**: テストファイルの該当シナリオ/関数へのリンク（相対パス）

```markdown
[正常計算](../../../tests/src/processor/test_wmape.py#L10)
```

**リンクが見つからない場合**（未カバー）:

```markdown
n=1 ← **未カバー**
```

> **注意**:
> - 行番号はおおよその位置で構わない。ファイルを開いた後にジャンプできれば十分。
> - 相対パスは `_docs/test-coverage/{issue-name}/` からの相対パス（通常 `../../../` でプロジェクトルートへ）

#### 「エラー処理」カラムの書き方

異常系テストでは、エラーの伝播経路を明記する:

| パターン | 記述例 | 意味 |
|---------|--------|------|
| 単一キャッチ | `ValueError→CLI` | CLIでキャッチして終了 |
| 連鎖 | `FileNotFoundError→Pipeline→CLI` | Pipeline経由でCLIへ伝播 |
| 変換 | `SchemaError(collect時)→ValueError→Pipeline` | collect時に発生し、ValueErrorに変換されてPipelineへ |
| 正常系/境界値 | `-` | エラー処理なし（ハイフンで表記） |

**連鎖の書き方**:
- `→` で伝播方向を示す
- 最終的にどこでキャッチされるかを末尾に
- LazyFrameのcollect時エラーは `(collect時)` を付記

#### 「説明」カラムの書き方

Featureシナリオの意図を自然言語で補足する:

- **何を**: どのデータ/状態に対して
- **どうなる**: 期待される結果・挙動
- **なぜ重要か**: テストする理由（境界値の場合は特に）

例:
| テストケース | 説明 |
|-------------|------|
| 正常計算 | 複数SKUの誤差データから指標を計算する |
| 空→NaN | SKUが0件の場合、除算不可のためNaNを返す |
| n=1 | SKUが1件のみの場合（統計量の特殊ケース） |
| null除外 | null値を含むSKUをJOIN前に除外する |

### 4. カテゴリ別チェックリスト

```markdown
## カテゴリ別チェックリスト

### 正常系 (Happy Path)
- [x] 基本的な入力で正しく動作する
- [x] 複数データで正しく動作する

### 境界値・エッジケース
- [x] 空データ (n=0)
- [ ] 単一データ (n=1) ← **未カバー**
- [x] 大量データ
- [ ] null/None値 ← **未カバー**

### 異常系
- [x] 不正な型
- [ ] 範囲外の値 ← **未カバー**
```

### 5. 推奨アクション

```markdown
## 推奨アクション

### Critical (必須)
1. **単一データケースのテスト追加**
   - 対象: Step 3 計算処理
   - コンポーネント: WmapeCalculator
   - 理由: n=1は標準偏差計算で特殊ケース

### Important (推奨)
2. **Bias%混在ケース追加**
   - 対象: Step 3 計算処理
   - コンポーネント: BiasPctCalculator
```

---

## 処理フロー連携

### processing-flow-docがある場合

1. `_docs/processing-flow/{issue-name}/`のドキュメントを読み込む
2. Mermaidフロー図をコピー
3. 各ブロックにテストカバレッジを付与
4. 未カバーブロックをハイライト

### processing-flow-docがない場合

1. ソースコードから処理フローを抽出
2. 簡易フロー図を生成
3. 各ステップのテストマトリクスを作成

---

## Mermaidスタイルガイド

### カバレッジ状態の色分け

| 状態 | 色 | スタイル |
|------|-----|---------|
| 全カバー (100%) | 緑 | `fill:#c8e6c9,stroke:#388e3c` |
| 一部未カバー (50-99%) | 黄 | `fill:#fff9c4,stroke:#f57c00` |
| Critical未カバー (<50%) | 赤 | `fill:#ffcdd2,stroke:#c62828` |
| 現在位置（詳細表示中） | 黄+太枠 | `fill:#ffeb3b,stroke:#f57c00,stroke-width:4px` |

### ブロックラベルフォーマット

```
"ステップ名<br/>✓ 3/4" または "ステップ名<br/>⚠ 2/4"
```

---

## テストカテゴリ

### 正常系 (Happy Path)

| カテゴリ | 確認内容 |
|---------|----------|
| 基本動作 | 典型的な入力で正しく動作するか |
| 複数データ | リスト・バッチ処理が正しいか |
| オプショナル | 省略可能フィールドの扱い |

### 境界値・エッジケース

| カテゴリ | 確認内容 | 例 |
|---------|----------|-----|
| 空データ | n=0の場合の挙動 | `[]`, 空DataFrame |
| 単一データ | n=1の場合の挙動 | 集計で特殊ケース |
| 最大値 | 上限付近の挙動 | 1e10, sys.maxsize |
| null/None | 欠損値の扱い | `None`, `NaN` |
| inf/-inf | 無限大の扱い | `float('inf')` |

### 異常系

| カテゴリ | 確認内容 | 例 |
|---------|----------|-----|
| 型エラー | 不正な型入力 | str vs float |
| 範囲外 | 許容範囲外の値 | 負値, 未来日付 |
| 不整合 | データ間の矛盾 | 参照先不在 |

### ビジネスロジック固有

| カテゴリ | 確認内容 |
|---------|----------|
| ドメインルール | ビジネス要件が満たされているか |
| 計算精度 | 数値計算が正確か |
| 状態遷移 | 状態変化が正しいか |

### データフロー

| カテゴリ | 確認内容 |
|---------|----------|
| 入出力整合性 | 入力DTOから出力DTOへの変換が正しいか |
| カラム保持 | 必要なカラムが失われていないか |
| 型維持 | データ型が意図通りか |

---

## 詳細リファレンス

- **テストカテゴリ詳細**: [references/test-categories.md](references/test-categories.md)
- **マトリクステンプレート**: [references/matrix-template.md](references/matrix-template.md)

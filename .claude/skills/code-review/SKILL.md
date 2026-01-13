---
name: code-review
description: |
  Use immediately when user mentions: "code review", "コードレビュー", "レビュー", "review", "品質", "quality", "チェック", "check", "lint", "format", "test", "type check", "pyright", "ruff", "pytest", "テスト", "フォーマット", "確認", "大丈夫".

  MUST USE this skill for:
  - Code review after implementation (data science focus)
  - Quality checks with ruff, pyright, pytest
  - Data leakage detection in ML code
  - Statistical validity verification
  - Architecture compliance checks
---

# コードレビュースキル

データサイエンスプロジェクト向けの体系的レビュー。

## レビューカテゴリ

| カテゴリ | 焦点 |
|---------|------|
| **設計原則** | YAGNI・KISS・SRP準拠（最優先） |
| **コード品質** | アーキテクチャ準拠、型安全性、不変性 |
| **データリーク** | 時間的リーク、ターゲットリーク、前処理順序 |
| **統計的妥当性** | CV戦略、評価指標、統計検定 |
| **再現性** | 乱数シード、環境記録、結果の再現 |

## レビューモード

ファイルパス・内容から自動判定:

| パス/内容 | モード | 厳格さ |
|----------|--------|--------|
| `experiments/` | 探索的 | 柔軟（主要な問題のみ） |
| `src/` | 本番 | 標準（全チェック） |
| `pipelines/` | 本番 | 厳格（リーク重点） |

## 0. 設計原則チェック（最優先・Critical）

**これらの違反は必ず指摘する。過剰実装は技術的負債。**

### YAGNI (You Aren't Gonna Need It)

```
□ すべての機能が明示的に要求されているか？
  → "将来使うかも"で実装した機能がないか？
□ 抽象化は3回以上使われることが確定しているか？
  → 使用箇所が2回以下の抽象化・基底クラスがないか？
□ ヘルパー関数は3回以上使われるか？
  → 1-2回しか使われていないヘルパー関数がないか？
□ 設定ファイル・DSLは明示的に要求されているか？
  → 不要な設定レイヤーがないか？
```

### KISS (Keep It Simple, Stupid)

```
□ 最もシンプルな解決策が選ばれているか？
  → 複雑なデザインパターンの過剰適用がないか？
□ クラスは適切なサイズか？
  → 200行超える場合（Pipeline除く）、適切に分割されているか？
□ ネストは3段階以内か？
  → 深いネストは関数抽出で解消されているか？
□ メソッドシグネチャはシンプルか？
  → 引数が4個以上ある場合、DTOにまとめられないか？
□ 不要なラッパーメソッドがないか？
  → 注入されたProcessorを呼び出すだけのメソッドは不要
  → 例: _step_xxx() が self._processor.process() を呼ぶだけ
  → 直接Processorを呼び出すべき
```

### SRP (Single Responsibility Principle)

```
□ 各クラスの責務は1つか？
  → クラスの説明に"and"が含まれていないか？
□ 各メソッドの操作は1つか？
  → メソッド名に"and"が含まれていないか？
□ ProcessorにI/O処理が含まれていないか？
  → I/O処理はdata_io/に分離されているか？
```

## 1. コード品質チェック

### アーキテクチャ準拠

```
□ schemas/: DTOのみ、s_*.py命名
□ interface/: Protocolのみ、I*命名
□ processor/: Stateless、I/O禁止
□ domain/: ビジネスロジック
□ pipelines/: オーケストレーションのみ
```

### 型安全性・不変性

```
□ 公開APIに型注釈があるか？
□ Any型が使われていないか？
□ DTOのin-place変更がないか？
□ model_copy(update=...)を使用しているか？
```

## 2. データリーク検出（重点項目）

### 時間的リーク（時系列必須）

```
□ 未来データが訓練に混入していないか？
  → 例: 翌日の売上を当日の特徴量に使用
□ Time Series CVを使用しているか？
  → ランダム分割は時系列では禁止
□ 週/月集計が未来を含んでいないか？
```

### ターゲットリーク

```
□ 目的変数から派生した特徴量がないか？
  → 例: 売上合計から計算した平均単価
□ 予測時点で利用不可能な情報がないか？
□ 異常に高い精度の特徴量がないか？
```

### 前処理順序リーク

```
□ スケーリング/欠損値処理はCV内で実施か？
  → train/test分割前の全データfit禁止
□ 特徴量選択はCV内で実施か？
□ 各fold独立に前処理しているか？
```

## 3. 統計的妥当性

### 交差検証

```
□ 適切なCV戦略か？
  → 時系列: TimeSeriesSplit / BlockedCV
  → グループ: GroupKFold
  → 不均衡: StratifiedKFold
□ fold数は十分か？（通常5-10）
□ nested CVでハイパラ調整しているか？
```

### 評価指標

```
□ 問題に適した指標か？
  → 不均衡: F1, MCC, AUC-PR（Accuracy禁止）
  → 回帰: MAE, RMSE, MAPE
□ 複数指標を報告しているか？
□ ベースライン（ダミー/単純モデル）と比較しているか？
```

### 統計検定

```
□ p値だけでなく効果量も報告しているか？
□ 多重比較補正を行っているか？
□ 検定の前提条件を確認しているか？
```

## 4. 再現性

```
□ 乱数シードが固定されているか？
  → np.random.seed(), random.seed(), torch.manual_seed()
□ 依存バージョンが記録されているか？
□ 結果を再実行で再現できるか？
```

## 5. レポート保存

**レビュー完了後、必ずマークダウンレポートを保存する。**

### ファイル配置

```
_docs/reviews/{issue-name}/{yyyyMMddHHmm}.md
```

ブランチ名が`{layer}/{issue-name}`の形式もしくは`{issue-name}`になっています。

例:
```
_docs/reviews/1-feat-implement-wmape/202601051026.md
_docs/reviews/2-feat-implement-bias-calculation/202601051130.md
```

### レポート構成

レビューレポートは以下の構成で作成する:

1. **Header**: 日付、ブランチ、レビュワー、レビューモード
2. **Executive Summary**: 全体ステータス、品質ツール結果、主要チェック項目
3. **Quality Tools Results**: ruff format, ruff check, pyright, pytest の詳細結果
4. **Design Principles Review**: YAGNI/KISS/SRP チェック結果
5. **Architecture Compliance**: ディレクトリ構造、命名規則、DI確認
6. **Type Safety & Immutability**: 型注釈、DTO不変性、ClassVar使用
7. **Data Leak / Statistical Validity / Reproducibility**: 該当する場合のみ
8. **Verified Items**: 問題なかった項目のリスト
9. **Issues Found & Fixed**: Critical, Important, Suggestions に分類
10. **Final Verdict**: 承認/却下、強み、品質メトリクス、推奨事項
11. **Files Reviewed**: レビュー対象ファイルのリスト
12. **Appendix**: ツール出力の詳細（該当する場合）

### ブランチ名・タイムスタンプ取得

```bash
# ブランチ名取得
git branch --show-current

# タイムスタンプ取得
date '+%Y%m%d%H%M'
```

### レポート作成フロー

1. 品質ツール実行 → 結果収集
2. 各カテゴリチェック → 問題・確認項目記録
3. レポート構成に従ってマークダウン作成
4. `_docs/reviews/{branch-name}/YYYYMMDDHHMM.md` に保存
5. ユーザーにファイルパスを報告

## 出力フォーマット（レビュー中の対話用）

レビュー実行中はこの形式でユーザーに報告:

```markdown
## Review: [ファイルパス]
Mode: 探索的 / 本番

### Critical（必須対応）
- Q: [質問形式で問題を指摘]
  → なぜ問題か: [理由]
  → 参照: [関連するガイドライン]

### Important（推奨対応）
- Q: [質問形式で問題を指摘]
  → なぜ問題か: [理由]

### Suggestions（提案）
- [改善案]

### Verified（確認済み）
- ✓ [問題なかった項目]
```

**レビュー完了後、上記「レポート保存」セクションに従ってマークダウンファイルを作成・保存すること。**

## 品質ツール

### 実行順序

```bash
# 1. フォーマット適用
uv run ruff format .

# 2. Lint自動修正
uv run ruff check --fix .

# 3. 型チェック
uv run pyright src scripts tests

# 4. テスト実行
uv run pytest
```

### チェックのみ（修正なし）

```bash
uv run ruff format --check .
uv run ruff check .
uv run pyright src scripts tests
uv run pytest
```

### 品質基準

| ツール | 基準 |
|--------|------|
| ruff format | 差分なし |
| ruff check | エラー0件 |
| pyright | エラー0件 |
| pytest | 全テストパス |

### 結果分析

**ruff エラー例:**
```
src/processor/transformer.py:15:5: F841 Local variable `x` is assigned but never used
```
→ 未使用変数を削除または使用

**pyright エラー例:**
```
src/domain/builder.py:23:12 - error: Argument of type "str" cannot be assigned to parameter "data" of type "SalesRecord"
```
→ 型不一致を修正

**pytest 失敗例:**
```
FAILED tests/src/schemas/test_s_records.py::test_validation - AssertionError
```
→ テストまたは実装を修正

### トラブルシューティング

| 問題 | 解決策 |
|------|--------|
| ruff が見つからない | `uv sync` |
| pyright エラー多数 | 特定ディレクトリのみ: `pyright src/schemas/` |
| テストが遅い | 並列: `pytest -n auto`、失敗のみ: `pytest --lf` |

## 詳細リファレンス

- **データリーク検出**: [references/leakage.md](references/leakage.md)
- **統計的妥当性**: [references/statistical.md](references/statistical.md)
- **コード品質**: [references/code-quality.md](references/code-quality.md)

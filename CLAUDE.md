# CLAUDE.md

**言語設定**: 日本語で応答（コミットメッセージ・PRタイトルは英語）

## 設計原則【最重要・必須遵守】

すべての設計・実装において以下の原則を厳守する：

### YAGNI (You Aren't Gonna Need It)
- **明示的に要求されていない機能は実装しない**
- 「将来必要になるかも」は実装理由にならない
- 3行の重複コードは抽象化しない（使い回しが3回以上確定してから）

### KISS (Keep It Simple, Stupid)
- **最も単純な解決策を選ぶ**
- 複雑な抽象化より、明示的で読みやすいコードを優先
- ヘルパー関数・ユーティリティは「実際に3回使われてから」作成

### SRP (Single Responsibility Principle)
- **1クラス＝1責務**
- ProcessorがI/O処理を含んでいたら分割
- 「〜と〜を行う」という説明なら2つに分けるべき

### Protocol-based DI (Dependency Injection)
- **具象クラスではなくProtocolに依存**
- コンストラクタ注入のみ（setter注入禁止）
- Protocolは`interface/`に配置

### Schema-First Development
- **実装前にDTO定義**
- 外部データ読み込み直後にDTOへ変換
- 生のdict/DataFrameを公開APIで返さない

---

## スキル起動ルール【最重要・必須遵守】

**タスクの種類に応じて、適切なスキルを起動すること。スキルを使って設計→実装→テスト→レビューを一つのコンテキストで完遂する。**

### スキル起動マッピング

ユーザーが以下を求めた場合、**即座に**対応スキルを起動:

| キーワード・状況 | 起動スキル | 起動コマンド |
|-----------------|----------|-------------|
| 「コードレビュー」「品質確認」「チェックして」「ruff」「pyright」「pytest」 | `code-review` | `Skill(skill="code-review")` |
| 「テスト書いて」「BDDシナリオ」「フィーチャーファイル」 | `bdd-testing` | `Skill(skill="bdd-testing")` |
| 「処理フロー」「フロー図」「Mermaid」「可視化」 | `processing-flow-doc` | `Skill(skill="processing-flow-doc")` |
| 「実験記録」「論文形式」「IMRaD」「レポート」 | `experiment-doc` | `Skill(skill="experiment-doc")` |
| 「DTO設計」「Pydantic」「バリデーション」 | `dto-design` | `Skill(skill="dto-design")` |
| 「Interface」「Protocol設計」「抽象化」 | `interface-design` | `Skill(skill="interface-design")` |
| 「Pipeline」「ワークフロー」「オーケストレーション」 | `pipelines-impl` | `Skill(skill="pipelines-impl")` |
| 「データI/O」「Loader」「Saver」「永続化」 | `data-io-impl` | `Skill(skill="data-io-impl")` |
| 「ワークフロー全体」「開発フロー」「実装フロー」 | `workflow-orchestrator` | `Skill(skill="workflow-orchestrator")` |
| 「テストのドキュメント」「テスト網羅性」「テストマトリクス」「テストカバー率」「テストケース一覧」「missing tests」「テストの漏れがないか」「what tests are needed」「テストをレビュー」「review tests」 | `test-coverage` | `Skill(skill="test-coverage")` |
| 「プロジェクト憲章」「charter」「プロジェクト定義」「Why/What/How」「目的整理」「スコープ定義」 | `project-charter` | `Skill(skill="project-charter")` |
| 「週報」「weekly report」「作業レポート」「進捗報告」「発信用レポート」 | `weekly-report` | `Skill(skill="weekly-report")` |

### 常時参照スキル【自動発火】

以下のスキルは実装作業開始時に**常に参照**すること:

| スキル | 目的 | 参照タイミング |
|--------|------|---------------|
| `project-knowledge` | プロジェクト固有知識の参照 | 新機能実装前、既存パターン確認時 |

**project-knowledge使用ルール**:
1. **実装前**: 関連するreferences/を確認し、既存パターンに従う
2. **実装後**: 新たなパターン・知見をreferences/に追記
3. **索引検索**: 各referenceファイルのYAML frontmatterでキーワード検索可能

### 実装フロー（一つのコンテキストで完結）

**CRITICAL**: 以下のフローを必ず完遂する。**テストフェーズを飛ばさない**。

1. **設計フェーズ**: 該当スキル起動（dto-design, interface-design等）
2. **実装フェーズ**: 設計に基づいて直接実装
3. **テストフェーズ**: `bdd-testing`スキル起動（**必須・実装完了時は必ず実行**）
4. **レビューフェーズ**: `code-review`スキル起動（**必須・テスト完了時は必ず実行**）

### 禁止事項【絶対遵守】

#### オーバーエンジニアリング禁止
- ❌ 要求されていない抽象化・汎用化
- ❌ 「将来使うかも」で作る拡張ポイント
- ❌ 使い回しが2回以下でのヘルパー関数作成
- ❌ 設定ファイル・DSLの導入（明示的要求なし）
- ❌ 過度なデザインパターンの適用

#### 実装フロー違反禁止
- ❌ `code-review`スキルを起動せずに実装完了とする
- ❌ `bdd-testing`スキルを起動せずに実装完了とする
- ❌ 品質チェック未実行のままコミットする
- ❌ スキル起動条件に該当するのにスキルを使わない

## クイックリファレンス

```bash
uv sync                                    # 依存関係インストール
uv run pytest                              # テスト実行
uv run ruff format . && uv run ruff check --fix .  # フォーマット＆リント
uv run pyright src scripts tests           # 型チェック
```

## アーキテクチャ

```
src/
├── schemas/      # Pydantic DTO (s_*.py)
├── interface/    # Protocol (I*)
├── domain/       # ビジネスロジック
├── processor/    # Stateless変換（純粋関数、状態なし）
├── transformer/  # Stateful変換（fit/transform、内部状態あり）
├── models/       # ML models (fit/predict)
├── pipelines/    # オーケストレーション
├── data_io/      # 外部I/O
└── utils/        # ユーティリティ
```

### ディレクトリ別スキル対応【実装時は必ず参照】

| ディレクトリ | スキル | 主要パターン |
|-------------|--------|-------------|
| schemas/ | `dto-design` | Pydantic, validator |
| interface/ | `interface-design` | Protocol, Generic |
| processor/ | （スキルなし・直接実装） | Stateless, process() |
| transformer/ | （スキルなし・直接実装） | fit/transform, 状態管理 |
| domain/ | （スキルなし・直接実装） | DI, ビジネスロジック |
| models/ | （スキルなし・直接実装） | IModel, fit/predict, get_state |
| pipelines/ | `pipelines-impl` | Constructor Injection, run() |
| data_io/ | `data-io-impl` | ILoader/ISaver, 即座DTO変換 |

## データ・実験ディレクトリ

```
data/
├── raw/      # 不変のソースデータ
├── interim/  # ブランチ別出力: interim/{branch-name}/
└── share/    # 共有リファレンスデータ
```

ブランチ名とディレクトリ名を一致させる:
- `experiment/feature-analysis` → `experiments/feature-analysis/`, `data/interim/feature-analysis/`

## コミットルール

- 英語、issue番号を末尾に
- AI署名・Coauthor禁止

## コーディング標準

自動適用ルール:
- `src/**/*.py` → `.claude/rules/coding.md`
- `tests/**/*.py` → `.claude/rules/testing.md`

## Fleeting Notes（暗黙知の蓄積）

ユーザーから指摘・修正・フィードバックを受けた場合、その内容を抽象化して `_docs/fleeting/` に蓄積する。

### 記録タイミング

- ❌ 「こうじゃなくて、こうして」という修正指示を受けたとき
- ❌ 期待と異なる出力をしてユーザーが訂正したとき
- ❌ 「次からは〜して」という要望を受けたとき
- ✅ ユーザーが暗黙的に期待していたパターンが判明したとき

### 記録フォーマット

```markdown
# {YYYYMMDDHHmm}_{トピック}.md

## 指摘内容
{ユーザーの指摘を簡潔に}

## 抽象化したルール
{この指摘から導かれる一般的なルール}

## 適用範囲
{どの状況でこのルールを適用すべきか}

## 関連
{既存のスキル/ルールとの関連があれば}
```

### 蓄積後の活用

fleeting notesが5件以上溜まったら:
1. 共通パターンを抽出
2. `.claude/rules/` にルール化、または `.claude/skills/` にスキル化を検討
3. CLAUDE.mdへの統合を提案

---
name: project-charter
description: |
  This skill should be used when the user asks to "プロジェクト憲章", "charter", "プロジェクト定義", "プロジェクト開始", "project kickoff", "Why/What/How", "目的を整理", "スコープ定義", "ゴール設定".

  MUST USE this skill for:
  - Creating project charter documents at project start
  - Clarifying project purpose (Why), deliverables (What), and approach (How)
  - Interviewing stakeholders to extract implicit project goals
  - Any work in _docs/charter/ directory
---

# Project Charter Skill

プロジェクト開始時に、ユーザーへのインタビューを通じてプロジェクト憲章を整理・文書化する。

## 概要

このスキルは**Planモード**で動作する：

1. `EnterPlanMode`でPlanモードに入る
2. `AskUserQuestion`でユーザーにインタビュー
3. 回答を整理してプラン（憲章ドラフト）を作成
4. `ExitPlanMode`でユーザー承認を得る
5. 承認後、`_docs/charter/{YYYYMMdd}.md`に保存

## インタビューフロー

### Phase 1: Why（なぜ）

**目的**: プロジェクトの存在意義を明確化

```
AskUserQuestion:
  question: "このプロジェクトはなぜ必要ですか？解決したい課題や背景を教えてください"
  header: "Why"
  options:
    - label: "業務課題の解決"
      description: "既存業務の非効率や問題を解決したい"
    - label: "新しい価値創出"
      description: "新機能・新サービスで価値を生み出したい"
    - label: "技術的負債の解消"
      description: "レガシーシステムの刷新・改善"
    - label: "その他"
      description: "上記以外の理由"
```

**フォローアップ質問**（回答に応じて）:
- 「現状どのような問題が発生していますか？」
- 「この課題を放置するとどうなりますか？」
- 「誰がこの問題で困っていますか？」

### Phase 2: What（何を）

**目的**: 成果物とスコープを明確化

```
AskUserQuestion:
  question: "このプロジェクトで何を作りますか？具体的な成果物を教えてください"
  header: "What"
  options:
    - label: "データ分析・ML"
      description: "予測モデル、分析レポート、ダッシュボード"
    - label: "アプリケーション"
      description: "Web/モバイルアプリ、API、ツール"
    - label: "インフラ・基盤"
      description: "パイプライン、プラットフォーム、自動化"
    - label: "その他"
      description: "上記以外の成果物"
```

**フォローアップ質問**:
- 「成功をどう測定しますか？KPIや目標値はありますか？」
- 「スコープ外（やらないこと）は何ですか？」
- 「最低限必要な機能（MVP）は何ですか？」

### Phase 3: How（どうやって）

**目的**: アプローチと制約を明確化

```
AskUserQuestion:
  question: "どのようなアプローチで進めますか？技術選定や制約があれば教えてください"
  header: "How"
  options:
    - label: "技術スタック指定あり"
      description: "使用する技術・フレームワークが決まっている"
    - label: "提案してほしい"
      description: "最適な技術選定を相談したい"
    - label: "既存システム連携"
      description: "既存システムとの統合が必要"
    - label: "その他"
      description: "上記以外のアプローチ"
```

**フォローアップ質問**:
- 「期限やマイルストーンはありますか？」
- 「チーム構成や役割分担は？」
- 「制約条件（予算、技術、セキュリティ）はありますか？」

### Phase 4: 確認と補足

**追加で確認すべき項目**:

```
AskUserQuestion:
  question: "他に共有しておきたい情報はありますか？"
  header: "補足"
  multiSelect: true
  options:
    - label: "ステークホルダー情報"
      description: "関係者、承認者、利用者について"
    - label: "リスク・懸念"
      description: "想定されるリスクや不安要素"
    - label: "参考情報"
      description: "既存ドキュメント、類似プロジェクト"
    - label: "特になし"
      description: "追加情報なし"
```

## 憲章ドキュメント構造

`_docs/charter/{YYYYMMdd}.md`:

```markdown
# プロジェクト憲章: {プロジェクト名}

**作成日**: YYYY-MM-DD
**ステータス**: Draft / Approved

---

## Executive Summary

{1-2文でプロジェクトを要約}

---

## 1. Why（なぜ）

### 1.1 背景・課題
{現状の課題、問題点}

### 1.2 目的
{このプロジェクトで解決したいこと}

### 1.3 期待される効果
{成功した場合のインパクト}

---

## 2. What（何を）

### 2.1 成果物
{具体的なデリバラブル}

### 2.2 成功指標（KPI）
| 指標 | 目標値 | 測定方法 |
|------|--------|----------|
| {KPI1} | {値} | {方法} |

### 2.3 スコープ

**In Scope（やること）**:
- {項目1}
- {項目2}

**Out of Scope（やらないこと）**:
- {項目1}
- {項目2}

---

## 3. How（どうやって）

### 3.1 アプローチ
{全体的な進め方}

### 3.2 技術スタック
| カテゴリ | 選定 | 理由 |
|----------|------|------|
| {言語} | {Python} | {理由} |

### 3.3 マイルストーン
| フェーズ | 内容 | 完了条件 |
|----------|------|----------|
| Phase 1 | {内容} | {条件} |

### 3.4 制約条件
- {制約1}
- {制約2}

---

## 4. 体制

### 4.1 ステークホルダー
| 役割 | 担当 | 責任 |
|------|------|------|
| {オーナー} | {名前} | {責任} |

### 4.2 コミュニケーション
- 定例: {頻度}
- 報告: {方法}

---

## 5. リスク

| リスク | 影響度 | 対策 |
|--------|--------|------|
| {リスク1} | High/Med/Low | {対策} |

---

## Appendix

### 参考情報
- {リンク、ドキュメント}

### 用語集
| 用語 | 定義 |
|------|------|
| {用語} | {定義} |
```

## 実行手順

### Step 1: Planモードに入る

```
EnterPlanMode()
```

### Step 2: インタビュー実施

Phase 1-4の質問を順番に実施。各回答を記録。

**インタビューのコツ**:
- 1度に質問は1-2個まで（ユーザーを圧倒しない）
- 回答が曖昧な場合はフォローアップ質問
- 「他には？」で追加情報を引き出す

### Step 3: プラン（憲章ドラフト）作成

収集した情報を整理し、憲章ドキュメント構造に従ってプランファイルに記述。

### Step 4: 承認を得る

```
ExitPlanMode()
```

ユーザーがプランを確認・承認。

### Step 5: ドキュメント保存

承認後、`_docs/charter/{YYYYMMdd}.md`に保存:

```bash
mkdir -p _docs/charter
```

```
Write(file_path="_docs/charter/{YYYYMMdd}.md", content="{憲章内容}")
```

## 質問のカスタマイズ

プロジェクトタイプに応じて質問を調整:

### データ分析プロジェクト
- 「どのようなデータを使いますか？」
- 「予測したい対象は何ですか？」
- 「精度の目標値はありますか？」

### アプリケーション開発
- 「想定ユーザーは誰ですか？」
- 「既存システムとの連携はありますか？」
- 「非機能要件（性能、セキュリティ）は？」

### インフラ・基盤構築
- 「現在の運用課題は何ですか？」
- 「可用性・信頼性の要件は？」
- 「移行計画は必要ですか？」

## 注意事項

- **言語化されていない暗黙知を引き出す**: ユーザーが明確に言語化できていない場合は、具体例や選択肢を提示
- **完璧を求めない**: 初期段階では不確定要素があって当然。「TBD」を許容
- **アップデート前提**: 憲章はプロジェクト進行に応じて更新可能

## 詳細ガイド

- **インタビューテクニック**: See [references/interview-guide.md](references/interview-guide.md)

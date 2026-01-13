---
name: workflow-orchestrator
description: |
  Use immediately when user mentions: "実装して", "implement", "機能追加", "feature", "作って", "create", "バグ修正", "fix", "実験", "experiment", "統合", "integrate", "ワークフロー", "workflow", "パイプライン", "pipeline".

  MUST USE this skill for:
  - Orchestrating multi-step development workflows
  - Coordinating specialized subagents (planner → schema-architect → implementer → test-writer → reviewer)
  - Managing feature implementation, bug fixes, experiments, and integration tasks

  **CRITICAL**: This skill defines the MANDATORY workflow. Never skip steps or bypass agents.
---

# Workflow Orchestrator

開発ワークフローをサブエージェントに委任して自動化する。

## サブエージェント一覧

| Agent | Color | 役割 | トリガー |
|-------|-------|------|---------|
| planner | cyan | 実装設計・コンポーネント分割 | "設計して", "どう分けるべき" |
| schema-architect | yellow | DTO/Interface設計 | "DTOを設計", "Interface定義" |
| implementer | magenta | コンポーネント実装 | "実装して", "Processorを作って" |
| test-writer | green | BDDテスト作成 | "テストを書いて", "カバレッジ" |
| reviewer | blue | コードレビュー・品質確認 | 実装完了後（自動）, "レビュー" |
| debugger | red | エラー調査・修正 | "エラー", "失敗", "動かない" |
| researcher | cyan | EDA・実験・仮説検証 | "実験", "分析", "仮説検証" |
| integrator | magenta | Pipeline統合 | "統合", "Pipeline作って" |
| reporter | green | ドキュメント作成 | "ドキュメント化", "レポート" |

## ワークフロー

### 1. 新機能開発 (implement-feature)

**トリガー**: "新機能を実装", "feature", "機能追加", "〜を作って"

```
Step 1: planner (opus)
  └─ 要件分析・コンポーネント設計
  └─ 出力: 実装計画、DTO/Interface仕様

Step 2: schema-architect (opus)
  └─ DTO/Interface実装
  └─ 出力: src/schemas/s_*.py, src/interface/i_*.py

Step 3: implementer (opus)
  └─ コンポーネント実装
  └─ 出力: src/{layer}/*.py

Step 4: test-writer (opus)
  └─ BDDテスト作成
  └─ 出力: tests/

Step 5: reviewer (opus) [必須]
  └─ 品質確認
  └─ 出力: レビューレポート

Step 6: reporter (opus) [推奨]
  └─ 処理フロードキュメント作成
  └─ 出力: PROCESSING_FLOW.md
```

### 2. バグ修正 (fix-bug)

**トリガー**: "バグ修正", "fix", "エラー", "動かない"

```
Step 1: debugger (opus)
  └─ エラー調査・原因特定・修正
  └─ 出力: 修正されたコード

Step 2: test-writer (opus)
  └─ 回帰テスト追加
  └─ 出力: tests/

Step 3: reviewer (opus) [必須]
  └─ 品質確認
```

### 3. 実験/EDA (run-experiment)

**トリガー**: "実験", "EDA", "仮説検証", "分析"

```
Step 1: researcher (opus)
  └─ 仮説設定・EDA実行
  └─ 出力: experiments/{branch}/, _docs/experiments/{branch}/
```

### 4. Pipeline統合 (integrate)

**トリガー**: "統合", "Pipeline作って", "組み合わせて"

```
Step 1: integrator (opus)
  └─ コンポーネント統合
  └─ 出力: src/pipelines/

Step 2: test-writer (opus)
  └─ E2Eテスト作成

Step 3: reviewer (opus) [必須]
  └─ 品質確認
```

## 実行ガイドライン

### ステップ間の引き継ぎ

各サブエージェントのプロンプトには以下を含める:

```python
Task(subagent_type="implementer", model="opus",
     prompt="""
前ステップの成果物:
- src/schemas/s_feature.py
- src/interface/i_processor.py

実装対象:
- src/processor/feature_processor.py

要件:
[具体的な要件]
""")
```

### エラーハンドリング

- 各ステップ完了後に結果を確認
- 失敗時はdebuggerに委任
- 必要に応じてAskUserQuestionで確認

### 並列実行

依存関係のないステップは並列実行可能:

```python
# 並列実行例
Task(subagent_type="test-writer", run_in_background=True, ...)
Task(subagent_type="reporter", run_in_background=True, ...)
TaskOutput(task_id=..., block=True)  # 完了待ち
```

## 制約

**MUST:**
- reviewer は最終ステップとして必須
- 各ステップ完了を確認してから次へ
- model="opus" を使用（品質確保）

**MUST NOT:**
- 品質確認なしで完了としない
- ユーザー確認なしにステップをスキップしない

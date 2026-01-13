---
name: experiment-doc
description: |
  Use immediately when user mentions: "実験", "experiment", "EDA", "探索的分析", "exploratory", "仮説", "hypothesis", "検証", "verify", "論文形式", "IMRaD", "レポート", "report", "分析結果", "analysis result".

  MUST USE this skill for:
  - Creating experiment documentation in academic paper format (IMRaD)
  - Recording hypotheses and experimental results
  - Documenting EDA findings with reproducibility standards
  - Any work in _docs/experiments/ or experiments/ directories
---

# Experiment Documentation (Academic Paper Format)

実験記録を学術論文形式（IMRaD）で作成する。

## IMRaD構造

| Section | 答えるべき問い | 必須要素 |
|---------|--------------|----------|
| Abstract | 要約は？ | 目的・方法・結果・結論（150語以内）|
| Introduction | なぜ？ | 背景・問題設定・仮説 |
| Methods | どうやって？ | データ・手法・環境・再現条件 |
| Results | 何がわかった？ | 定量結果・図表・統計 |
| Discussion | 何を意味する？ | 解釈・限界・次のステップ |

## ファイル配置

```
_docs/experiments/{branch-name}/YYYYMMDDHHMM.md
```

## テンプレート

```markdown
# {実験タイトル}

**Author**: {name} | **Date**: YYYY-MM-DD | **Branch**: experiment/{name}

## Abstract

{1段落で目的・方法・主要結果・結論を記述。150語以内。}

## 1. Introduction

### 1.1 Background
{なぜこの実験が必要か。先行研究や既存の課題。}

### 1.2 Research Question
{明確な問い。例: "特徴量Xは予測精度を改善するか？"}

### 1.3 Hypothesis
{検証可能な仮説。例: "H1: 特徴量Xを追加するとRMSEが5%以上改善する"}

## 2. Methods

### 2.1 Data
| 項目 | 値 |
|------|-----|
| Source | {データソース} |
| Period | {期間} |
| N (train/val/test) | {サンプル数} |
| Features | {特徴量数} |

### 2.2 Experimental Design
{実験の設計。比較条件、CV戦略（時系列ならTimeSeriesSplit）}

### 2.3 Implementation
- Environment: Python {version}, {主要ライブラリ}
- Random seed: 42
- Code: `experiments/{branch-name}/`

### 2.4 Evaluation Metrics
{使用するメトリクス。例: RMSE, MAE, R², AUC}

## 3. Results

### 3.1 Main Results
| Model | Metric1 | Metric2 | 備考 |
|-------|---------|---------|------|
| Baseline | x.xx | x.xx | |
| Proposed | x.xx | x.xx | |

### 3.2 Figures
![Figure 1: {説明}](data/interim/{branch}/outputs/figures/fig1.png)

### 3.3 Statistical Significance
{必要に応じて: p値、信頼区間、効果量}

## 4. Discussion

### 4.1 Interpretation
{結果の解釈。仮説は支持されたか？}

### 4.2 Limitations
{この実験の限界。データの制約、手法の制約}

### 4.3 Future Work
{次のステップ。追加実験、本番適用への道筋}

## References
{参照した論文、ドキュメント}

## Appendix
{補足情報: 詳細なパラメータ、追加の図表}
```

## 再現性チェックリスト

実験完了時に確認:

- [ ] Random seed固定（42）
- [ ] 環境情報記録（Python, ライブラリバージョン）
- [ ] データ分割が適切（時系列なら未来データ漏洩なし）
- [ ] コードが `experiments/{branch}/` に保存
- [ ] 出力が `data/interim/{branch}/outputs/` に保存
- [ ] 図表に軸ラベル・タイトルあり

## 詳細ガイド

- **論文セクション詳細**: See [references/imrad-guide.md](references/imrad-guide.md)
- **再現性チェックリスト**: See [references/reproducibility.md](references/reproducibility.md)
- **図表スタイル**: See [references/figures.md](references/figures.md)

---
paths:
  - _docs/experiments/**/*.md
  - experiments/**/*.{py,ipynb}
---

# Documentation Standards

## Experiment Documentation

**Location:** `_docs/experiments/{branch-name}/YYYYMMDDHHMM.md`

**IMRaD形式（学術論文標準）:**

| Section | 答えるべき問い | 必須要素 |
|---------|--------------|----------|
| Abstract | 要約は？ | 目的・方法・結果・結論（150語以内）|
| Introduction | なぜ？ | 背景・問題設定・仮説 |
| Methods | どうやって？ | データ・手法・環境・再現条件 |
| Results | 何がわかった？ | 定量結果・図表・統計 |
| Discussion | 何を意味する？ | 解釈・限界・次のステップ |

## Branch-Directory Mapping

| Branch | Code | Data |
|--------|------|------|
| `experiment/{name}` | `experiments/{name}/` | `data/interim/{name}/` |
| `feature/{name}` | `src/` | - |

## Output Organization

```
data/interim/{branch-name}/outputs/
├── figures/    # Visualizations
├── reports/    # CSVs, summaries
└── results/    # Model outputs, metrics
```

## Code Naming Conventions

Experiment scripts use numbered prefixes for execution order:
- `00_data_exploration.ipynb`
- `01_feature_engineering.py`
- `02_model_training.ipynb`

## 再現性チェックリスト

実験完了時に確認:
- [ ] Random seed固定（42）
- [ ] 環境情報記録（Python, ライブラリバージョン）
- [ ] データ分割が適切（時系列なら未来データ漏洩なし）
- [ ] コードが `experiments/{branch}/` に保存
- [ ] 出力が `data/interim/{branch}/outputs/` に保存
- [ ] 図表に軸ラベル・タイトルあり

## Documentation Requirements

**MUST:**
- Document every experiment in `_docs/experiments/{branch-name}/`
- Store outputs in `data/interim/{branch-name}/outputs/`
- Use numbered prefixes for execution order
- Include visualization paths in documentation
- Follow IMRaD structure for experiment reports

**MUST NOT:**
- Leave experiments undocumented
- Skip hypothesis or success criteria
- Mix outputs from different branches

## 詳細リファレンス

IMRaD詳細ガイド、再現性チェックリスト、図表スタイル → `experiment-doc`スキル

# ML実験の再現性チェックリスト

Based on: [ML Reproducibility Checklist (NeurIPS)](https://jmlr2020.csail.mit.edu/papers/volume22/20-303/20-303.pdf), [Nature Methods Standards](https://pmc.ncbi.nlm.nih.gov/articles/PMC9131851/)

## 実験前チェックリスト

### 環境設定
- [ ] Pythonバージョン固定
- [ ] 依存ライブラリをlockファイルで固定（`uv.lock`）
- [ ] Random seedを設定ファイルで一元管理
- [ ] GPUを使う場合は`CUBLAS_WORKSPACE_CONFIG`設定

```python
# 推奨設定
RANDOM_SEED = 42

import random
import numpy as np

random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)

# PyTorch使用時
import torch
torch.manual_seed(RANDOM_SEED)
torch.backends.cudnn.deterministic = True
torch.backends.cudnn.benchmark = False
```

### データ準備
- [ ] データソースをコードまたはドキュメントに記録
- [ ] 前処理ステップを明文化
- [ ] Train/Val/Test分割を固定（シャッフル時はseed固定）
- [ ] 欠損値処理を記録

### 実験設計
- [ ] ベースラインを設定
- [ ] 比較条件を明確化
- [ ] 評価指標を事前定義
- [ ] 統計的検定の計画（必要な場合）

---

## 実験中チェックリスト

### コード管理
- [ ] 実験開始前にgit commit
- [ ] 実験結果にcommit hashを紐付け
- [ ] 中間結果を定期保存

### ログ記録
- [ ] ハイパーパラメータを全て記録
- [ ] 学習曲線（loss, metrics）を保存
- [ ] 実行時間を記録
- [ ] エラー・警告を記録

### データ漏洩チェック
- [ ] テストデータが学習に混入していないか確認
- [ ] 前処理パラメータ（平均、標準偏差）がtrainデータのみから計算されているか
- [ ] 時系列データで未来情報が漏洩していないか
- [ ] Target leakageがないか（ターゲットから派生した特徴量）

---

## 実験後チェックリスト

### 結果の保存
- [ ] モデルの重み/パラメータを保存
- [ ] 予測結果を保存
- [ ] 評価メトリクスを保存
- [ ] 図表を保存（パスをドキュメントに記録）

### ドキュメント
- [ ] 実験ドキュメント作成（IMRaD形式）
- [ ] 環境情報をREADMEまたはドキュメントに記録
- [ ] 実行手順を記録

### 検証
- [ ] 別seedで再実行して結果の安定性確認
- [ ] 極端なケースでの挙動確認
- [ ] 結果が合理的か確認（sanity check）

---

## 環境情報テンプレート

ドキュメントに以下を記録:

```markdown
## Environment

### Hardware
- CPU: {model}
- RAM: {size}
- GPU: {model} (if used)

### Software
- OS: {name} {version}
- Python: {version}
- Key packages:
  - polars: {version}
  - scikit-learn: {version}
  - xgboost: {version}

### Reproducibility Settings
- Random seed: 42
- Git commit: {hash}
- Experiment date: YYYY-MM-DD
```

---

## よくある再現性の問題

| 問題 | 原因 | 対策 |
|------|------|------|
| 毎回結果が異なる | Random seed未固定 | 全ての乱数生成箇所でseed固定 |
| 他環境で動かない | ライブラリバージョン差異 | lockファイルで依存関係固定 |
| GPU結果が異なる | 非決定的演算 | `CUBLAS_WORKSPACE_CONFIG=:4096:8` |
| データが見つからない | パスのハードコード | 相対パスまたは設定ファイルで管理 |
| 前処理が再現できない | 手順未記録 | パイプラインとしてコード化 |

---

## 統計的妥当性チェック

### 複数回実行
- 最低5回の異なるseedで実行
- 平均 ± 標準偏差を報告
- 信頼区間を計算

### 有意差検定
- 対応のあるt検定（同一データでの比較）
- Wilcoxon符号順位検定（正規性仮定なし）
- Bonferroni補正（複数比較時）

### 報告フォーマット
```markdown
| Model | RMSE (mean±std) | 95% CI | p-value |
|-------|-----------------|--------|---------|
| Baseline | 0.93±0.04 | [0.89, 0.97] | - |
| Proposed | 0.82±0.03 | [0.79, 0.85] | <0.001 |
```

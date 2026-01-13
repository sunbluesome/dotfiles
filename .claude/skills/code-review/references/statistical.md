# 統計的妥当性リファレンス

## 交差検証戦略

### データ特性別CV選択

| データ特性 | 推奨CV | 理由 |
|-----------|--------|------|
| 時系列 | TimeSeriesSplit | 未来→過去の情報漏洩防止 |
| グループ依存 | GroupKFold | 同一グループを分離 |
| 不均衡クラス | StratifiedKFold | クラス比率を維持 |
| 小データ | RepeatedKFold | 分散を低減 |
| 通常 | KFold (5-10) | 標準的選択 |

### 時系列CV

```python
from sklearn.model_selection import TimeSeriesSplit

# 基本的なTime Series Split
tscv = TimeSeriesSplit(n_splits=5)

# ギャップ付き（情報漏洩防止強化）
tscv = TimeSeriesSplit(n_splits=5, gap=7)  # 7日のギャップ

# 拡張ウィンドウ vs スライディングウィンドウ
# 拡張: 訓練データが累積
# スライディング: 固定サイズのウィンドウが移動
```

### Nested CV（ハイパラ調整）

```python
from sklearn.model_selection import cross_val_score, GridSearchCV

# NG: 同じCVでハイパラ調整と評価
grid = GridSearchCV(model, params, cv=5)
score = cross_val_score(grid, X, y, cv=5)  # 同じ5-fold

# OK: Nested CV
outer_cv = KFold(n_splits=5)
inner_cv = KFold(n_splits=3)

scores = []
for train_idx, test_idx in outer_cv.split(X):
    grid = GridSearchCV(model, params, cv=inner_cv)
    grid.fit(X[train_idx], y[train_idx])
    scores.append(grid.score(X[test_idx], y[test_idx]))
```

## 評価指標

### 分類問題

| 状況 | 推奨指標 | 非推奨 |
|------|---------|--------|
| 不均衡データ | F1, MCC, AUC-PR | Accuracy |
| コスト非対称 | Weighted F1, カスタム | F1 (macro) |
| 確率出力重視 | Brier Score, Log Loss | - |
| ランキング | AUC-ROC, MAP | Accuracy |

```python
# 不均衡データでの評価
from sklearn.metrics import (
    f1_score,
    matthews_corrcoef,
    average_precision_score,
    classification_report,
)

# 複数指標を報告
print(classification_report(y_true, y_pred))
print(f"MCC: {matthews_corrcoef(y_true, y_pred):.3f}")
print(f"AUC-PR: {average_precision_score(y_true, y_prob):.3f}")
```

### 回帰問題

| 状況 | 推奨指標 | 注意点 |
|------|---------|--------|
| 一般的 | RMSE, MAE | スケール依存 |
| 相対誤差 | MAPE, SMAPE | ゼロ近傍で不安定 |
| 外れ値あり | MAE, Huber | RMSEは外れ値に敏感 |
| 説明力 | R² | 負になることもある |

```python
# 複数指標を報告
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
import numpy as np

y_pred = model.predict(X_test)
print(f"MAE: {mean_absolute_error(y_test, y_pred):.3f}")
print(f"RMSE: {np.sqrt(mean_squared_error(y_test, y_pred)):.3f}")
print(f"R²: {r2_score(y_test, y_pred):.3f}")
```

### ベースライン比較

```python
from sklearn.dummy import DummyClassifier, DummyRegressor

# 分類: 最頻値予測
baseline = DummyClassifier(strategy="most_frequent")

# 回帰: 平均値予測
baseline = DummyRegressor(strategy="mean")

# 時系列: 直前の値（ナイーブ予測）
y_naive = y_test.shift(1)
```

## 統計検定

### モデル比較

| 比較対象 | 推奨検定 | 前提条件 |
|---------|---------|---------|
| 2モデル（1データセット） | McNemar検定 | 分類 |
| 2モデル（複数fold） | Wilcoxon符号順位検定 | 対応あり |
| 複数モデル | Friedman検定 + Nemenyi | 3群以上 |

```python
from scipy import stats

# Wilcoxon符号順位検定（対応あり）
stat, p_value = stats.wilcoxon(scores_model_a, scores_model_b)

# 効果量（Cohen's d）
def cohens_d(a, b):
    return (np.mean(a) - np.mean(b)) / np.sqrt((np.var(a) + np.var(b)) / 2)

d = cohens_d(scores_model_a, scores_model_b)
print(f"p={p_value:.4f}, Cohen's d={d:.3f}")
```

### 多重比較補正

```python
from statsmodels.stats.multitest import multipletests

# Bonferroni補正
_, p_adjusted, _, _ = multipletests(p_values, method="bonferroni")

# Benjamini-Hochberg（FDR制御）
_, p_adjusted, _, _ = multipletests(p_values, method="fdr_bh")
```

### p値の解釈

| p値 | 効果量 | 解釈 |
|-----|--------|------|
| < 0.05 | 大 (d > 0.8) | 実用的に有意 |
| < 0.05 | 小 (d < 0.2) | 統計的のみ有意 |
| > 0.05 | - | 有意差なし |

## 信頼区間・不確実性

```python
import numpy as np
from scipy import stats

# CVスコアの信頼区間
scores = cross_val_score(model, X, y, cv=10)
mean = scores.mean()
se = scores.std() / np.sqrt(len(scores))
ci = stats.t.interval(0.95, len(scores)-1, loc=mean, scale=se)

print(f"Mean: {mean:.3f} (95% CI: [{ci[0]:.3f}, {ci[1]:.3f}])")
```

## チェックリスト

```
□ データ特性に適したCV戦略を選択したか？
□ 複数の評価指標を報告したか？
□ ベースラインモデルと比較したか？
□ 統計検定で効果量も報告したか？
□ 多重比較補正を行ったか？
□ 信頼区間または分散を報告したか？
```

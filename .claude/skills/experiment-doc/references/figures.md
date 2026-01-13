# 学術論文スタイルの図表ガイド

Based on: [Nature Figure Guidelines](https://www.nature.com/nature/for-authors/formatting-guide)

## 基本原則

1. **Self-contained**: 図表だけで内容が理解できる
2. **Simple**: 必要最小限の情報のみ
3. **Consistent**: スタイルを統一

---

## 図（Figure）

### 必須要素

```
+----------------------------------+
|          [グラフ本体]              |
|                                  |
|  Y軸ラベル（単位）                  |
|          ↓                       |
|    ┌─────────────┐              |
|    │             │              |
|    │   データ     │              |
|    │             │              |
|    └─────────────┘              |
|           X軸ラベル（単位）         |
|                                  |
|    ● Condition A  ○ Condition B  | ← 凡例
+----------------------------------+
Figure 1: タイトル（説明文）         | ← キャプション
```

### キャプションの書き方

**構成:**
1. 図番号とタイトル（太字）
2. 図の説明（1-2文）
3. 凡例の説明
4. 統計情報（n, p値など）

**例:**
> **Figure 1: Comparison of prediction accuracy across models.** RMSE values for baseline and proposed models across 5-fold cross-validation. Error bars represent 95% confidence intervals. n=5 folds per model. ***p<0.001 (paired t-test).

### 色使い

**カラーパレット（色覚多様性対応）:**
```python
# Matplotlib用
colors = {
    'blue': '#0077BB',    # 青
    'orange': '#EE7733',  # オレンジ
    'green': '#009988',   # 緑
    'magenta': '#EE3377', # マゼンタ
    'gray': '#BBBBBB',    # グレー
}
```

**ルール:**
- 色だけでなく形状・パターンでも区別
- 赤/緑の組み合わせを避ける
- 重要な要素は高コントラスト

### Matplotlibテンプレート

```python
import matplotlib.pyplot as plt

# 論文スタイル設定
plt.rcParams.update({
    'font.size': 10,
    'font.family': 'sans-serif',
    'axes.labelsize': 10,
    'axes.titlesize': 11,
    'xtick.labelsize': 9,
    'ytick.labelsize': 9,
    'legend.fontsize': 9,
    'figure.figsize': (6, 4),
    'figure.dpi': 150,
    'savefig.dpi': 300,
    'savefig.bbox': 'tight',
})

# プロット
fig, ax = plt.subplots()
ax.plot(x, y, 'o-', label='Model A')
ax.set_xlabel('Time (days)')
ax.set_ylabel('RMSE')
ax.set_title('Model Performance Over Time')
ax.legend()
ax.grid(True, alpha=0.3)

# 保存
fig.savefig('data/interim/{branch}/outputs/figures/fig1.png')
```

---

## 表（Table）

### 基本フォーマット

```markdown
| Model | RMSE | MAE | R² |
|:------|-----:|----:|---:|
| Baseline | 0.93 | 0.71 | 0.82 |
| Proposed | 0.82 | 0.63 | 0.87 |
```

**ルール:**
- 数値は右揃え
- 文字は左揃え
- 小数点以下の桁数を揃える
- 単位を列ヘッダーに含める

### 結果表のベストプラクティス

**良い例:**
```markdown
**Table 1: Model comparison results**

| Model | RMSE (↓) | MAE (↓) | R² (↑) | Training Time (s) |
|:------|----------|---------|--------|------------------:|
| Baseline | 0.93±0.04 | 0.71±0.03 | 0.82±0.02 | 12.3 |
| +Lag7 | **0.82±0.03** | **0.63±0.02** | **0.87±0.01** | 15.7 |
| +Lag14 | 0.85±0.03 | 0.65±0.02 | 0.85±0.02 | 14.2 |

Bold indicates best performance. (↓) lower is better, (↑) higher is better.
Mean±SD across 5 folds.
```

### ハイパーパラメータ表

```markdown
**Table 2: Hyperparameter settings**

| Parameter | Search Range | Best Value |
|:----------|:-------------|:-----------|
| max_depth | [3, 5, 7, 9] | 5 |
| learning_rate | [0.01, 0.1] | 0.05 |
| n_estimators | [100, 500] | 300 |
| min_child_weight | [1, 3, 5] | 3 |
```

---

## 図表の配置

### ファイル構成

```
data/interim/{branch}/outputs/
├── figures/
│   ├── fig1_model_comparison.png
│   ├── fig2_feature_importance.png
│   └── fig3_learning_curve.png
├── tables/
│   ├── table1_results.csv
│   └── table2_hyperparams.csv
└── reports/
    └── summary.csv
```

### 命名規則

```
fig{番号}_{内容}_v{バージョン}.png
```

例:
- `fig1_rmse_comparison.png`
- `fig2_feature_importance_v2.png`

---

## 図の種類と用途

| 図の種類 | 用途 | 注意点 |
|---------|------|--------|
| 折れ線グラフ | 時系列、学習曲線 | X軸は連続値 |
| 棒グラフ | カテゴリ比較 | Y軸は0から開始 |
| 箱ひげ図 | 分布の比較 | 外れ値を明示 |
| 散布図 | 相関、2変数関係 | 回帰線追加可 |
| ヒートマップ | 相関行列、混同行列 | カラーバー必須 |
| バイオリンプロット | 分布の形状 | サンプル数も表示 |

---

## チェックリスト

### 図
- [ ] タイトルがある
- [ ] 軸ラベルがある（単位含む）
- [ ] 凡例がある（必要な場合）
- [ ] フォントサイズが読める
- [ ] 色が区別できる
- [ ] 解像度が十分（300 DPI以上）
- [ ] キャプションが完全

### 表
- [ ] 列ヘッダーが明確
- [ ] 単位が明記されている
- [ ] 数値の桁数が揃っている
- [ ] 最良値が強調されている
- [ ] 注釈が付いている（必要な場合）

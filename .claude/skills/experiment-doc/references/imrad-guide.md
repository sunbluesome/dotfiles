# IMRaD論文形式詳細ガイド

学術論文の標準構造であるIMRaD形式に基づく実験記録の書き方。

## 1. Abstract（要旨）

### 目的
論文全体を1段落で要約。読者が読むべきか判断する材料。

### 構成（150語以内）
1. **目的**: 1-2文で研究の目的
2. **方法**: 1-2文で手法の概要
3. **結果**: 2-3文で主要な発見
4. **結論**: 1文で意義・インパクト

### 例
> We investigated whether adding temporal features improves sales prediction accuracy. Using 24 months of transaction data (N=50,000), we compared XGBoost models with and without lag features using 5-fold time series cross-validation. The model with lag features achieved RMSE of 0.82 (95% CI: 0.79-0.85), a 12% improvement over baseline (p<0.001). These results suggest temporal patterns are significant predictors for this domain.

### 禁止事項
- 略語の初出定義なしでの使用
- 結果に含まれない内容への言及
- 主観的評価（"interesting", "important"）

---

## 2. Introduction（序論）

### 構造: 逆三角形
```
広い背景 → 具体的問題 → この研究の位置づけ → 仮説
```

### 2.1 Background（背景）

**書くべき内容:**
- 研究分野の現状
- 先行研究のサマリ
- 既存手法の限界

**例:**
> 時系列予測において、特徴量エンジニアリングは精度向上の重要な要素である（Smith et al., 2023）。しかし、ラグ特徴量の最適なウィンドウサイズについては、ドメインごとに異なり、一般的な指針が確立されていない。

### 2.2 Research Question（研究課題）

**良い例:**
- "Does adding lag features (7, 14, 30 days) improve prediction accuracy?"
- "What is the optimal window size for capturing seasonal patterns?"

**悪い例:**
- "Is this model good?" （曖昧）
- "Can we predict sales?" （Yes/Noで答えられない）

### 2.3 Hypothesis（仮説）

**SMART仮説:**
- **S**pecific: 具体的
- **M**easurable: 測定可能
- **A**chievable: 達成可能
- **R**elevant: 関連性がある
- **T**ime-bound: 期限がある（実験では指標で代替）

**例:**
> H1: 7日間のラグ特徴量を追加することで、RMSEが5%以上改善する
> H0: ラグ特徴量の追加はRMSEに有意な影響を与えない

---

## 3. Methods（方法）

### 原則
**再現可能性**: 第三者が同じ結果を得られる詳細さ

### 3.1 Data（データ）

必須記載項目:
| 項目 | 例 |
|------|-----|
| Source | BigQuery: `project.dataset.table` |
| Period | 2022-01-01 to 2023-12-31 |
| Granularity | Daily aggregation |
| N (total) | 50,000 records |
| N (train/val/test) | 35,000 / 7,500 / 7,500 |
| Missing values | 2.3%, imputed with median |
| Outlier treatment | Winsorized at 1st/99th percentile |

### 3.2 Experimental Design（実験設計）

**比較実験の場合:**
```
| Condition | Description |
|-----------|-------------|
| Baseline | XGBoost with original features |
| +Lag7 | Baseline + 7-day lag features |
| +Lag14 | Baseline + 14-day lag features |
| +Lag30 | Baseline + 30-day lag features |
```

**CV戦略:**
- 時系列: TimeSeriesSplit（未来データ漏洩防止）
- IID: StratifiedKFold
- グループ: GroupKFold

### 3.3 Implementation（実装）

```markdown
**Environment:**
- Python 3.11.4
- polars==0.20.0
- scikit-learn==1.4.0
- xgboost==2.0.3

**Reproducibility:**
- Random seed: 42
- Code: `experiments/feature-analysis/`
- Commit: abc1234
```

### 3.4 Evaluation Metrics（評価指標）

| メトリクス | 定義 | 用途 |
|-----------|------|------|
| RMSE | $\sqrt{\frac{1}{n}\sum(y-\hat{y})^2}$ | 回帰、外れ値に敏感 |
| MAE | $\frac{1}{n}\sum|y-\hat{y}|$ | 回帰、外れ値に頑健 |
| MAPE | $\frac{100}{n}\sum|\frac{y-\hat{y}}{y}|$ | 相対誤差 |
| R² | $1 - \frac{SS_{res}}{SS_{tot}}$ | 説明率 |
| AUC | ROC曲線下面積 | 分類、閾値非依存 |

---

## 4. Results（結果）

### 原則
**事実のみ**: 解釈はDiscussionで

### 4.1 Main Results

**表の書き方:**
```markdown
| Model | RMSE | MAE | R² | Δ RMSE |
|-------|------|-----|-----|--------|
| Baseline | 0.93 | 0.71 | 0.82 | - |
| +Lag7 | 0.82 | 0.63 | 0.87 | -11.8% |
| +Lag14 | 0.85 | 0.65 | 0.85 | -8.6% |
| +Lag30 | 0.88 | 0.68 | 0.84 | -5.4% |
```

### 4.2 Statistical Significance

**報告すべき統計量:**
- 平均値 ± 標準偏差
- 95%信頼区間
- p値（有意水準明記）
- 効果量（Cohen's d等）

**例:**
> The +Lag7 model achieved RMSE of 0.82 ± 0.03 (mean ± SD across 5 folds), significantly lower than baseline 0.93 ± 0.04 (paired t-test, p < 0.001, Cohen's d = 2.75).

### 4.3 Figures

**必須要素:**
- タイトル
- 軸ラベル（単位含む）
- 凡例
- キャプション

---

## 5. Discussion（考察）

### 5.1 Interpretation（解釈）

仮説との対応:
```markdown
**H1: 7日間のラグ特徴量でRMSEが5%以上改善する**
→ **支持**: +Lag7モデルはRMSEを11.8%改善（5%の閾値を超過）

この改善は、週次の購買パターンをモデルが捉えたことに起因すると考えられる。
```

### 5.2 Limitations（限界）

記載すべき限界:
- **データの限界**: サンプルサイズ、期間、偏り
- **手法の限界**: モデルの仮定、ハイパーパラメータ探索範囲
- **一般化の限界**: 他ドメインへの適用可能性

**例:**
> This study has several limitations. First, the data covers only 24 months, which may not capture long-term trends. Second, hyperparameter tuning was limited to default Optuna settings (100 trials). Third, results may not generalize to other product categories.

### 5.3 Future Work（今後の展望）

具体的で実行可能な提案:
- 追加実験の方向性
- 本番適用へのステップ
- 残された課題

---

## Quick Reference

| セクション | 時制 | 人称 |
|-----------|------|------|
| Abstract | 過去・現在 | We/This study |
| Introduction | 現在 | 受動態中心 |
| Methods | 過去 | We/受動態 |
| Results | 過去 | We |
| Discussion | 現在・過去 | We |

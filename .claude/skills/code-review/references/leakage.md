# データリーク検出リファレンス

## リークの種類

### 1. 時間的リーク（Temporal Leakage）

予測時点では利用できない未来の情報が訓練に混入。

**検出パターン:**

```python
# NG: 未来の情報を使用
df["next_day_sales"] = df["sales"].shift(-1)  # 翌日売上
df["week_avg"] = df.groupby("week")["sales"].transform("mean")  # 週全体の平均

# OK: 過去の情報のみ使用
df["prev_day_sales"] = df["sales"].shift(1)  # 前日売上
df["rolling_7d"] = df["sales"].rolling(7, closed="left").mean()  # 過去7日平均
```

**チェック質問:**
- この特徴量は予測時点で本当に利用可能か？
- `.shift(-n)` や未来方向の `rolling` がないか？
- 集計が未来のデータを含んでいないか？

### 2. ターゲットリーク（Target Leakage）

目的変数から直接・間接に派生した情報が特徴量に混入。

**検出パターン:**

```python
# NG: ターゲットから派生
df["avg_price"] = df["total_sales"] / df["quantity"]  # total_salesがターゲット関連
df["customer_ltv"] = df.groupby("customer_id")["target"].transform("sum")

# 要確認: 相関が異常に高い特徴量
high_corr = df.corr()["target"].abs().sort_values(ascending=False)
# 相関 > 0.95 は要調査
```

**チェック質問:**
- この特徴量はターゲットなしで計算できるか？
- 異常に予測力が高い特徴量がないか？
- 本番環境でこの特徴量は利用可能か？

### 3. 前処理リーク（Preprocessing Leakage）

CV/train-test分割前に全データで前処理を実行。

**検出パターン:**

```python
# NG: 分割前にfit
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)  # 全データでfit
X_train, X_test = train_test_split(X_scaled)

# OK: CV内でfit
for train_idx, test_idx in kfold.split(X):
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X[train_idx])
    X_test_scaled = scaler.transform(X[test_idx])
```

**チェック質問:**
- `fit()` は訓練データのみで行われているか？
- 特徴量選択は各foldで独立に行われているか？
- 欠損値補完の統計量は訓練データのみから計算しているか？

### 4. サンプルリーク（Sample Leakage）

同一サンプルや重複データがtrain/testに分散。

**検出パターン:**

```python
# NG: 重複がtrain/testに分散
df_train, df_test = train_test_split(df)  # 重複行があると危険

# 確認方法
duplicates = df.duplicated(subset=["id"])
print(f"重複行: {duplicates.sum()}")

# OK: グループ単位で分割
from sklearn.model_selection import GroupKFold
gkf = GroupKFold(n_splits=5)
for train_idx, test_idx in gkf.split(X, y, groups=df["user_id"]):
    # 同一ユーザーは同じfoldに
```

**チェック質問:**
- 重複行は除去されているか？
- 同一ユーザー/エンティティは同じfoldにあるか？
- データ拡張はtrain分割後に行われているか？

## 時系列特有のリーク

### Blocked Cross-Validation

```python
# NG: 時系列でランダム分割
kfold = KFold(n_splits=5, shuffle=True)

# OK: 時系列CV
from sklearn.model_selection import TimeSeriesSplit
tscv = TimeSeriesSplit(n_splits=5)

# OK: ブロックCV（ギャップあり）
for i in range(n_folds):
    train_end = train_size + i * step
    test_start = train_end + gap  # ギャップで漏洩防止
    test_end = test_start + test_size
```

### 特徴量計算の時点管理

```python
# NG: 全期間で統計量計算
df["mean_sales"] = df.groupby("store")["sales"].transform("mean")

# OK: 過去データのみで統計量計算
df = df.sort_values("date")
df["mean_sales"] = df.groupby("store")["sales"].transform(
    lambda x: x.expanding().mean().shift(1)
)
```

## リーク検出のシグナル

以下の場合はリークを疑う:

| シグナル | 確認方法 |
|---------|---------|
| 異常に高い精度 | ベースラインと比較 |
| CV > 本番精度 | holdout/本番データで検証 |
| 特定特徴量の圧倒的重要度 | feature importance確認 |
| foldごとの精度差 | CV各foldの精度比較 |

## 防止策チェックリスト

```
□ 時系列データはTimeSeriesSplit使用
□ 前処理パイプラインはscikit-learn Pipeline使用
□ 特徴量計算は予測時点を意識
□ ハイパラ調整はnested CV
□ 最終評価は完全holdoutデータ
□ 本番と同じ特徴量計算ロジック使用
```

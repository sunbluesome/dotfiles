---
paths: tests/**/*.py
---

# Testing Standards (BDD/pytest-bdd)

## Structure

```
tests/
├── features/src/<module>/<n>.feature
├── src/<module>/test_*.py
└── conftest.py
```

Link features to tests:
```python
from pytest_bdd import scenarios
scenarios("src/<module>/<n>.feature")
```

## Step Implementation

### Given (Setup)
- Create test data as table → DataFrame/DTO
- Pass DTO through schema validation
- Reuse helpers from `tests/conftest.py`

### When (Action)
- Call target function/method
- Arguments and returns must be DTOs
- No external I/O allowed

### Then (Assertion)
- Verify DTO type compliance
- Check shape, columns, row counts
- Validate immutability preserved
- For errors: check exception type AND message fragment

## テストカテゴリ

### 正常系（Happy Path）
- 基本作成、境界値、オプショナル、複数データ

### 異常系（Edge Cases）

| カテゴリ | テスト内容 | 例 |
|---------|----------|-----|
| 欠損値 | null/None/欠落 | `quantity: null` |
| 無効値 | inf, nan, 負値 | `quantity: -1` |
| 型間違い | 期待と異なる型 | `String` vs `Float64` |
| 空データ | 空リスト/DataFrame | `[]` |

### 数値・行列系

| カテゴリ | テスト内容 |
|---------|----------|
| スカラー境界 | 0, 1, 1e10, inf, -inf, nan |
| ベクトル | 空, 長さ不一致, ゼロベクトル |
| 行列 | 形状(0,n), (n,0), 行数不一致 |
| 数値精度 | `pytest.approx`, 非負制約 |

### 日付系

| カテゴリ | テスト内容 |
|---------|----------|
| 年境界 | 12/31→1/1, 週番号切り替え |
| 月境界 | 月末→月初, 月初フラグ |
| 特殊日 | うるう年2/29, 祝日 |
| 曜日・週 | isoweekday, 週開始日truncate |

## コンポーネント別テスト

| 対象 | 正常系 | 異常系 |
|------|--------|--------|
| DTO | 作成・プロパティ | null/inf/nan/型間違い |
| Processor | 変換の正確性 | 空入力・無効入力 |
| Transformer | fit/transform整合性 | 未fitでtransform |
| Model | fit/predict動作 | 未fitでpredict |
| Pipeline | E2E処理 | 途中エラーの伝播 |

## Mock Policy

**Always Mock:** External networks, file system, databases
**Never Mock:** Domain logic, processor transformations
**Verify:** Call count, arguments, retry behavior

## Determinism

- Fix random seeds explicitly
- Set tolerances for float comparisons
- Avoid `sleep()` - use proper synchronization

## Error Testing

```python
def test_validation_error():
    with pytest.raises(ValueError, match="expected pattern"):
        function_that_raises()
```

## 詳細リファレンス

Gherkin構文、Step定義パターン → `bdd-feature`スキル

---
name: dto-design
description: |
  Use immediately when user mentions: "DTO", "スキーマ", "schema", "データモデル", "data model", "Pydantic", "validation", "バリデーション", "型定義", "type definition", "data structure", "レコード", "record".

  MUST USE this skill for:
  - Designing Pydantic DTOs with field validation
  - Creating type-safe data structures
  - Implementing validators and model configurations
  - Any work in src/schemas/ directory
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# DTO設計スキル

## 配置ルール

DTOは `src/schemas/s_*.py` に配置する。

```
src/schemas/
├── s_records.py      # 販売記録DTO
├── s_features.py     # 特徴量DTO
└── s_predictions.py  # 予測結果DTO
```

## Schema-First Development

1. **実装前にDTO定義** - コンポーネント実装の前にまずDTOを定義
2. **I/O直後にDTO変換** - 外部データ読み込み直後にDTOへ変換
3. **公開APIはDTO** - 生のDataFrame/dictを返さない

## 設計原則（YAGNI/KISS/SRP）

### YAGNI (You Aren't Gonna Need It)
- **明示的に必要なフィールドのみ定義**
- 「将来使うかも」で追加のフィールドを作らない
- オプショナルフィールド（`T | None`）は実際に欠損値が来る場合のみ使用

### KISS (Keep It Simple, Stupid)
- **複雑なvalidatorより、シンプルな型制約を優先**
- 継承より、フラットな構造を優先
- 計算プロパティは最小限（読み取り専用で明確な場合のみ）

### SRP (Single Responsibility Principle)
- **1 DTO = 1データ構造**
- DTO内にビジネスロジックを含めない
- バリデーションはデータ整合性チェックのみ（変換処理はProcessorへ）

## 命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| ファイル | `s_*.py` | `s_records.py` |
| クラス | PascalCase（DTO suffix/prefix禁止） | `SalesRecord`, `DesignMatrix` |
| フィールド | snake_case | `product_id`, `sales_quantity` |

**クラス命名の注意:**
- `SalesRecordDTO` → `SalesRecord` （DTOを付けない）
- `DTOSalesRecord` → `SalesRecord` （DTOを付けない）
- ファイル名の `s_` プレフィックスでスキーマであることを示す

## バリデーション

```python
from pydantic import BaseModel, field_validator, model_validator

class SalesRecord(BaseModel):
    product_id: str
    quantity: int

    @field_validator("quantity")
    @classmethod
    def quantity_must_be_positive(cls, v: int) -> int:
        if v < 0:
            raise ValueError("quantity must be non-negative")
        return v

    @model_validator(mode="after")
    def validate_consistency(self) -> "SalesRecord":
        # 複数フィールド間の整合性チェック
        return self
```

## 不変性

DTOは不変として扱う:

```python
# 良い例: model_copyで新しいインスタンスを作成
updated = original.model_copy(update={"quantity": 10})

# 悪い例: 直接変更（禁止）
original.quantity = 10  # NG
```

## 型安全性

- **明示的な型注釈** - すべてのフィールドに型を指定
- **`Any`禁止** - 具体的な型を使用
- **Nullable型** - `None`可能な場合は `T | None` を使用（`Optional[T]`は使わない）

```python
# 良い例
product_id: str
quantity: int
discount: float | None = None

# 悪い例
product_id: Any  # NG
data: dict  # NG - 具体的な型を使う
```

## LazyFrameを持つDTOのパターン

`pl.LazyFrame` を持つ DTO では以下の ClassVar を定義:

```python
from typing import ClassVar
import polars as pl
from pydantic import BaseModel, ConfigDict

class SalesRecord(BaseModel):
    """売上レコードDTO"""

    model_config = ConfigDict(arbitrary_types_allowed=True)

    # 1. カラム名定数（マジックストリング排除）
    SELLER_ID: ClassVar[str] = "seller_id"
    DATE: ClassVar[str] = "date"
    QUANTITY: ClassVar[str] = "quantity"

    # 2. Polarsスキーマ（カラム名定数を参照）
    SCHEMA: ClassVar[dict[str, pl.DataType]] = {
        SELLER_ID: pl.String,
        DATE: pl.Date,
        QUANTITY: pl.Float64,
    }

    # 3. オプショナルスキーマ（後から追加されるカラム）
    OPTIONAL_SCHEMA: ClassVar[dict[str, pl.DataType]] = {}

    # 4. Hiveパーティションスキーマ（オプション）
    HIVE_SCHEMA: ClassVar[dict[str, pl.DataType]] = {}

    data: pl.LazyFrame
```

**利用側でのカラム名参照**:
```python
# Good: ClassVar定数を使用
df.select(pl.col(SalesRecord.SELLER_ID))

# Bad: マジックストリング（禁止）
df.select(pl.col("seller_id"))
```

## 継承ルール

- **ファイル間継承禁止** - DTOの継承は同一ファイル内のみ許可
- **コンポジション優先** - 継承より依存注入を使用
- 例外: Protocol実装による具象クラス作成は許可

## 禁止パターン

- `Any`型の使用
- 生の`dict`/`DataFrame`を公開APIで返す
- in-placeでのフィールド変更
- バリデーションなしでの外部データ受け入れ
- カラム名をマジックストリングで使用（ClassVar定数を使う）
- 別ファイルのDTOを継承する

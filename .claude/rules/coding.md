---
paths: src/**/*.py
---

# Coding Standards

## Architecture Principles

### Design Principles (YAGNI/KISS/SRP) - CRITICAL

**これらの原則に違反するコードはレビューで却下される**

#### YAGNI (You Aren't Gonna Need It)
- **明示的に要求されていない機能は実装しない**
- 「将来使うかも」は実装理由にならない
- 抽象化は3回以上使われることが確定してから
- ヘルパー関数は3回以上の使用箇所が確定してから作成

#### KISS (Keep It Simple, Stupid)
- **最も単純な解決策を選ぶ**
- 複雑な抽象化より、明示的で読みやすいコードを優先
- 1クラス200行以内を目安に（超える場合は分割検討、Pipelineは除く）
- 深いネスト（3段階以上）は避ける

#### SRP (Single Responsibility Principle)
- **1クラス＝1責務、1メソッド＝1操作**
- クラスの説明に「〜と〜を行う」があれば分割
- メソッド名に "and" があれば分割検討

### Schema-First Development
- Define DTOs in `schemas/s_*.py` before any implementation
- Use `@field_validator`, `@model_validator` for validation
- Convert to DTO immediately after I/O operations

### Interface-Driven Design
- Implement Protocols from `interface/`
- Inject dependencies via interfaces
- Never depend on concrete implementations directly

### No Implicit Dependencies
- **`hasattr`/`getattr`による条件分岐は禁止** - DTOの構造を知っている前提のコードは暗黙的な依存関係を生む
- DTOは明示的なスキーマ（`SCHEMA` ClassVar）を持つこと
- 動的スキーマが必要な場合はDTOを分割する（例: `ForecastWide` → `ForecastRenamed`）
- 処理の入力型と出力型は明示的にすること

### Responsibility Separation

| Directory | Purpose | Rules |
|-----------|---------|-------|
| `schemas/` | DTO definitions | Pydantic models, validation logic |
| `interface/` | Contracts | Protocols with Generic/ParamSpec |
| `domain/` | Business logic | Use cases, policies, rules |
| `processor/` | Stateless transforms | Pure functions, no state, DTO→DTO |
| `transformer/` | Stateful transforms | fit/transform pattern, learned params |
| `models/` | ML | fit/transform/predict, interface compliant |
| `data_io/` | External I/O | File/DB/S3, immediate DTO conversion |
| `pipelines/` | Orchestration | Control flow only, delegate logic |
| `utils/` | Utilities | Cross-cutting, no business logic |

### Processor vs Transformer

**判断基準:**
- 変換ルールが固定 → Processor (`process()`)
- 変換ルールをデータから学習 → Transformer (`fit()`/`transform()`)

## Naming Conventions

- DTO files: `s_*.py`
- Interfaces: `I*` prefix
- Builders: `*Builder`
- Converters: `*Converter`
- Transformers: `*Transformer`
- Pipelines: `*Pipeline`
- Functions: verb-based
- Variables: descriptive nouns (no abbreviations)

## Type Safety

- Explicit annotations on all public APIs
- `Any` is forbidden
- Use `T | None` for nullable (not `Optional[T]`)
- Raise `ValueError`/`TypeError` immediately on type mismatches
- Never suppress exceptions silently

## Immutability

- Use `model_copy(update=...)` for modifications
- Return new instances, never mutate in place
- Processors must be side-effect free
- Transformers: internal state only modified in `fit()`

## Inheritance Rules

- **Cross-file inheritance is prohibited** for schemas and interfaces
  - Exception: Implementing a Protocol to create a concrete class is allowed
- **Same-file inheritance only**: If class B needs to inherit from class A, both must be in the same file
- **Prefer composition over inheritance**: Use dependency injection instead of inheritance hierarchies
- This prevents spaghetti code and keeps module boundaries clean

## Prohibited Patterns

### 絶対禁止（レビューで必ず指摘される）
- `Any` type usage
- `Optional[T]` (use `T | None` instead)
- In-place DataFrame mutations
- I/O operations in Processor/Transformer classes
- Business logic in `utils/` or `pipelines/`
- Returning raw DataFrames/dicts from public APIs

### オーバーエンジニアリング禁止
- ❌ 要求されていない抽象化・汎用化
- ❌ 「将来使うかも」で作る拡張ポイント
- ❌ 使い回しが2回以下でのヘルパー関数作成
- ❌ 設定ファイル・DSLの導入（明示的要求なし）
- ❌ 過度なデザインパターンの適用
- ❌ 基底クラスの乱用（継承は同一ファイル内のみ）
- ❌ `hasattr`/`getattr`による条件分岐（暗黙的な依存関係）
- ❌ 不要なラッパーメソッド（Processorを呼ぶだけの`_step_xxx()`等）
- Exception suppression (bare `except:` or `pass`)
- Cross-file inheritance (see Inheritance Rules above)
- `transform()` without prior `fit()` in Transformers

## 詳細リファレンス

各レイヤーの詳細パターン・実装例は対応スキルを参照:
- DTO → `dto-design`, Interface → `interface-design`
- 各レイヤー → `processor-impl`, `transformer-impl`, `domain-impl`, `models-impl`, `pipelines-impl`, `data-io-impl`

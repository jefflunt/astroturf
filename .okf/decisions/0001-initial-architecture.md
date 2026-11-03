# ADR 0001: Initial Architecture and Matrix Design

## Context
When performing large-scale architectural refactors or AI-assisted system rewrites, existing test data strategies (such as manual fixtures or procedural factories) test only a sparse subset of happy-path states. Hidden edge cases (such as unhandled enum combinations, boolean permutations, or foreign key cascades) are frequently missed.

Astroturf was conceived to aim for total coverage of value and combination space through declarative YAML matrices.

## Decisions

1. **Pure Ruby In-Memory Hashes as Primary Representation**:
   - Astroturf builds pure Ruby hashes first without requiring an active database connection or ActiveRecord dependency.
   - Decoupling generation from ORM storage allows maximum generation speed and makes equivalence comparison straightforward.

2. **Full Cartesian Product by Default**:
   - Attribute dimensions are computed as full Cartesian products.
   - For nested associations (`has_many`), the default mode is `:combinations`, providing each parent record with the full combination matrix of child records.
   - An optional `:count` mode is supported when fixed cardinality is desired per parent.

3. **Deterministic Fixture-Style Slug Labels**:
   - Records receive semantic labels derived from entity names and matrix coordinates (e.g. `user_admin_active_true`).
   - Labels make test failures and refactor diffs immediately diagnosable.

4. **Pluggable Primary Key Strategies**:
   - Supports monotonic integer sequences (`1, 2, 3...`) with configurable start/step offsets.
   - Supports deterministic RFC 4122 UUIDv5 values generated from record labels to ensure consistency across runs.
   - Supports custom callable procs.

5. **Self-Contained Inflection**:
   - Includes a lightweight `Astroturf::Inflector` for singular/plural/tableize conversions, avoiding a mandatory heavyweight dependency on ActiveSupport for basic usage.

6. **Ruby 3.4/4.0 Compatibility**:
   - Explicitly adds `ostruct` as a development dependency in the gemspec to prevent `LoadError` when Rake tasks run under modern Ruby environments where `ostruct` is a bundled gem.

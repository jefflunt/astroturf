# Astroturf

Exhaustive synthetic data generator for Rails and Ruby applications.

---

## Why Astroturf?

Most test suites test only the happy path.

Hand-written fixtures rot. Factory builders are slow and sample only a tiny fraction of valid states. When you undertake a large architectural overhaul or an automated AI-driven refactoring pass, hidden edge cases surface in production: an unhandled enum state, a `nil` middle name, an unexpected boolean combination, or a broken foreign key relationship.

**Astroturf aims for total coverage of your value and combination space.**

You define the dimensions in a YAML file. Astroturf computes the Cartesian product across every attribute, wires relational foreign keys, generates deterministic labels, and produces in-memory datasets in milliseconds.

Use these datasets to:
- Verify behavioral equivalence before and after sweeping refactors.
- Generate deterministic Rails fixtures (`test/fixtures/*.yml`).
- Seed development databases with every permutation of your domain model.

---

## Features

- **Full Cartesian Matrix Generation**: Computes every combination across arbitrary attribute dimensions.
- **Relational Graph Wiring**: Supports nested `has_many` and `has_one` hierarchies with automatic foreign key resolution.
- **Two Association Modes**:
  - `mode: combinations` (default): Generates the full Cartesian explosion of child records for every parent record.
  - `mode: count`: Cycles or samples a fixed count of children per parent.
- **Semantic Fixture Labels**: Automatically names records from their matrix values (e.g., `user_admin_active_true`, `user_admin_post_draft`).
- **Pluggable Primary Keys**:
  - Sequential integers (`1, 2, 3...`) with configurable starting points and steps.
  - Deterministic RFC 4122 UUIDv5 strings based on record labels.
  - Custom callable procs.
- **Attribute Interpolation**: Dynamically references `%{label}`, `%{seq}`, `%{id}`, parent attributes (`%{parent.label}`, `%{parent.id}`), or current matrix values in string templates.
- **Zero External Dependencies**: Pure Ruby. Generates fast in-memory hashes without requiring an active database connection.

---

## The Matrix Specification: `astroturf.yml`

```yaml
users:
  primary_key: integer  # Options: integer (default), uuid, or hash options
  matrix:
    role: [admin, member, guest]
    status: [active, suspended]
    email_verified: [true, false]
  defaults:
    name: "User %{label}"
    email: "%{label}@example.com"
    created_at: 2026-01-01 00:00:00 UTC

  has_many:
    # Mode 1: Full Cartesian Explosion (Default)
    # 12 users * 4 post combinations = 48 posts total
    posts:
      mode: combinations
      matrix:
        visibility: [public, private]
        published: [true, false]
      defaults:
        title: "Post for %{parent.label}"

    # Mode 2: Fixed Cardinality
    # Each user gets exactly 2 tokens
    tokens:
      mode: count
      count: 2
      defaults:
        token: "tok_%{parent.id}_%{seq}"

  has_one:
    profile:
      defaults:
        bio: "Bio for %{parent.label}"
```

---

## Usage

### 1. Generate In-Memory Hashes

```ruby
require "astroturf"

dataset = Astroturf.load_file("astroturf.yml")
# or: dataset = Astroturf.load(yaml_string_or_hash)

# Access all generated tables and records
dataset.tables.keys
# => ["users", "posts", "tokens", "profiles"]

# Inspect a single table
users = dataset["users"]
# => {
#   "user_admin_active_true" => {
#     "id" => 1,
#     "role" => "admin",
#     "status" => "active",
#     "email_verified" => true,
#     "name" => "User user_admin_active_true",
#     "email" => "user_admin_active_true@example.com",
#     "created_at" => 2026-01-01 00:00:00 UTC
#   },
#   ...
# }

# Total record count
dataset.total_records
# => 74
```

### 2. Export Rails Fixtures

Generate standard Rails fixture YAML strings or write them directly to your test suite:

```ruby
# Export as a YAML string for a single table
yaml_output = dataset.to_fixtures("users")

# Write .yml fixture files directly to disk
dataset.write_fixtures!("test/fixtures")
# Creates:
#   test/fixtures/users.yml
#   test/fixtures/posts.yml
#   test/fixtures/tokens.yml
#   test/fixtures/profiles.yml
```

---

## Primary Key Strategies

### Integer Sequences (Default)

```yaml
users:
  primary_key: integer
  # Or with custom offset and step:
  # primary_key:
  #   type: integer
  #   start_at: 1000
  #   step: 5
```

### Deterministic UUIDs

Astroturf produces RFC 4122 UUIDv5 values derived from the record's label. Generating the same dataset always produces identical UUIDs.

```yaml
accounts:
  primary_key: uuid
  matrix:
    plan: [free, pro]
```

---

## Running Tests

Run the test suite using Rake:

```bash
bundle exec rake test
```

Or run tests directly with Ruby:

```bash
ruby -Ilib -Itest test/astroturf_test.rb
ruby -Ilib -Itest test/matrix_test.rb
ruby -Ilib -Itest test/primary_key_test.rb
ruby -Ilib -Itest test/labeler_test.rb
ruby -Ilib -Itest test/definition_test.rb
ruby -Ilib -Itest test/generator_test.rb
ruby -Ilib -Itest test/dataset_test.rb
ruby -Ilib -Itest test/inflector_test.rb
```

---

## License

This project is available as open source under the terms of the [MIT License](LICENSE.txt).
Authored by Jeff Lunt (<jefflunt@gmail.com>).

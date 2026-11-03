# frozen_string_literal: true

require "test_helper"

class GeneratorTest < Minitest::Test
  def test_single_model_cartesian_generation
    yaml = <<~YAML
      users:
        matrix:
          role: [admin, member]
          active: [true, false]
        defaults:
          email: "%{label}@example.com"
          tag: "user_%{role}"
    YAML

    dataset = Astroturf.load(yaml)
    users = dataset["users"]

    assert_equal 4, users.size
    assert users.key?("user_admin_true")
    assert users.key?("user_admin_false")
    assert users.key?("user_member_true")
    assert users.key?("user_member_false")

    admin_true = users["user_admin_true"]
    assert_equal 1, admin_true["id"]
    assert_equal "admin", admin_true["role"]
    assert_equal true, admin_true["active"]
    assert_equal "user_admin_true@example.com", admin_true["email"]
    assert_equal "user_admin", admin_true["tag"]
  end

  def test_nested_has_many_combinations_mode
    # 2 users * 2 posts = 4 posts total
    yaml = <<~YAML
      users:
        matrix:
          role: [admin, guest]
        has_many:
          posts:
            mode: combinations
            matrix:
              published: [true, false]
            defaults:
              title: "Post for %{parent.label}"
    YAML

    dataset = Astroturf.load(yaml)
    assert_equal 2, dataset["users"].size
    assert_equal 4, dataset["posts"].size

    user_admin = dataset["users"]["user_admin"]
    admin_posts = dataset["posts"].values.select { |p| p["user_id"] == user_admin["id"] }
    assert_equal 2, admin_posts.size

    post_labels = admin_posts.map { |p| p["title"] }
    assert_equal ["Post for user_admin", "Post for user_admin"], post_labels
  end

  def test_nested_has_many_count_mode
    yaml = <<~YAML
      users:
        matrix:
          tier: [gold, silver]
        has_many:
          tokens:
            mode: count
            count: 3
            defaults:
              value: "tok_%{seq}"
    YAML

    dataset = Astroturf.load(yaml)
    assert_equal 2, dataset["users"].size
    # 2 users * 3 tokens = 6 tokens
    assert_equal 6, dataset["tokens"].size

    user_gold = dataset["users"]["user_gold"]
    gold_tokens = dataset["tokens"].values.select { |t| t["user_id"] == user_gold["id"] }
    assert_equal 3, gold_tokens.size
    assert_equal %w[tok_1 tok_2 tok_3], gold_tokens.map { |t| t["value"] }
  end

  def test_nested_has_one
    yaml = <<~YAML
      users:
        matrix:
          role: [lead, dev]
        has_one:
          profile:
            defaults:
              bio: "Bio for %{parent.label}"
    YAML

    dataset = Astroturf.load(yaml)
    assert_equal 2, dataset["users"].size
    assert_equal 2, dataset["profiles"].size

    user_lead = dataset["users"]["user_lead"]
    profile = dataset["profiles"]["user_lead_profile"]
    assert_equal user_lead["id"], profile["user_id"]
    assert_equal "Bio for user_lead", profile["bio"]
  end

  def test_uuid_primary_keys
    yaml = <<~YAML
      accounts:
        primary_key: uuid
        matrix:
          plan: [free, pro]
        has_many:
          memberships:
            primary_key: uuid
            mode: count
            count: 1
    YAML

    dataset = Astroturf.load(yaml)
    account_free = dataset["accounts"]["account_free"]
    assert_match PrimaryKeyTest::UUID_REGEX, account_free["id"]

    membership = dataset["memberships"].values.first
    assert_match PrimaryKeyTest::UUID_REGEX, membership["id"]
    assert_equal account_free["id"], membership["account_id"]
  end

  def test_deep_nesting
    yaml = <<~YAML
      organizations:
        matrix:
          org_type: [enterprise]
        has_many:
          teams:
            matrix:
              squad: [alpha, beta]
            has_many:
              tasks:
                mode: count
                count: 2
    YAML

    dataset = Astroturf.load(yaml)
    assert_equal 1, dataset["organizations"].size
    assert_equal 2, dataset["teams"].size
    assert_equal 4, dataset["tasks"].size
  end
end

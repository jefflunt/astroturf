# frozen_string_literal: true

require "test_helper"

class LabelerTest < Minitest::Test
  def test_generate_simple_label
    label = Astroturf::Labeler.generate("user", { "role" => "admin", "status" => "active" })
    assert_equal "user_admin_active", label
  end

  def test_generate_label_with_parent
    label = Astroturf::Labeler.generate(
      "post",
      { "status" => "draft" },
      parent_label: "user_admin_active"
    )
    assert_equal "user_admin_active_post_draft", label
  end

  def test_generate_label_with_booleans_and_nils
    label = Astroturf::Labeler.generate(
      "user",
      { "verified" => true, "deleted" => false, "archived_at" => nil }
    )
    assert_equal "user_true_false_nil", label
  end

  def test_sanitization_removes_invalid_characters
    label = Astroturf::Labeler.generate(
      "special-item!",
      { "category" => "Tech & Gadgets / Hardware", "tag" => "foo@bar#baz" }
    )
    assert_equal "special_item_tech_gadgets_hardware_foo_bar_baz", label
  end

  def test_generate_label_with_sequence
    label = Astroturf::Labeler.generate(
      "user",
      { "role" => "admin" },
      sequence: 42
    )
    assert_equal "user_admin_42", label
  end
end

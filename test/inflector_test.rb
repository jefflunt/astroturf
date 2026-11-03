# frozen_string_literal: true

require "test_helper"

class InflectorTest < Minitest::Test
  def test_singularize
    assert_equal "user", Astroturf::Inflector.singularize("users")
    assert_equal "post", Astroturf::Inflector.singularize("posts")
    assert_equal "category", Astroturf::Inflector.singularize("categories")
    assert_equal "address", Astroturf::Inflector.singularize("addresses")
    assert_equal "person", Astroturf::Inflector.singularize("people")
    assert_equal "child", Astroturf::Inflector.singularize("children")
  end

  def test_pluralize
    assert_equal "users", Astroturf::Inflector.pluralize("user")
    assert_equal "posts", Astroturf::Inflector.pluralize("post")
    assert_equal "categories", Astroturf::Inflector.pluralize("category")
    assert_equal "addresses", Astroturf::Inflector.pluralize("address")
    assert_equal "people", Astroturf::Inflector.pluralize("person")
    assert_equal "children", Astroturf::Inflector.pluralize("child")
  end

  def test_tableize
    assert_equal "users", Astroturf::Inflector.tableize("User")
    assert_equal "blog_posts", Astroturf::Inflector.tableize("BlogPost")
    assert_equal "categories", Astroturf::Inflector.tableize("Category")
  end
end

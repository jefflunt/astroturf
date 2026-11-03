# frozen_string_literal: true

require "test_helper"

class DefinitionTest < Minitest::Test
  def test_parse_simple_definition
    hash = {
      "users" => {
        "matrix" => { "role" => %w[admin member] },
        "defaults" => { "name" => "Default Name" }
      }
    }

    definitions = Astroturf::Definition.from_hash(hash)
    assert_equal 1, definitions.size

    user_def = definitions.first
    assert_equal "users", user_def.name
    assert_equal "users", user_def.table_name
    assert_equal "user_id", user_def.foreign_key_name
    assert_equal 2, user_def.matrix.size
    assert_equal({ "name" => "Default Name" }, user_def.defaults)
  end

  def test_parse_associations
    hash = {
      "users" => {
        "has_many" => {
          "posts" => {
            "matrix" => { "status" => %w[draft published] }
          },
          "comments" => {
            "mode" => "count",
            "count" => 3
          }
        },
        "has_one" => {
          "profile" => {
            "defaults" => { "bio" => "Hello" }
          }
        }
      }
    }

    definitions = Astroturf::Definition.from_hash(hash)
    user_def = definitions.first

    assert_equal 3, user_def.associations.size

    posts_assoc = user_def.associations.find { |a| a.name == "posts" }
    assert posts_assoc.has_many?
    assert_equal :combinations, posts_assoc.mode

    comments_assoc = user_def.associations.find { |a| a.name == "comments" }
    assert comments_assoc.has_many?
    assert_equal :count, comments_assoc.mode
    assert_equal 3, comments_assoc.count

    profile_assoc = user_def.associations.find { |a| a.name == "profile" }
    assert profile_assoc.has_one?
  end
end

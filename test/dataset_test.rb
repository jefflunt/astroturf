# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class DatasetTest < Minitest::Test
  def setup
    @data = {
      "users" => {
        "user_admin" => { "id" => 1, "role" => "admin" },
        "user_member" => { "id" => 2, "role" => "member" }
      },
      "posts" => {
        "user_admin_post_1" => { "id" => 10, "user_id" => 1, "title" => "First" }
      }
    }
    @dataset = Astroturf::Dataset.new(@data)
  end

  def test_table_access_and_records
    assert_equal %w[users posts], @dataset.table_names
    assert_equal 3, @dataset.total_records
    assert_equal 2, @dataset.records("users").size
    assert_equal 1, @dataset.records("posts").size
  end

  def test_to_fixtures_single_table
    fixtures = @dataset.to_fixtures("users")
    parsed = YAML.safe_load(fixtures)
    assert_equal 2, parsed.size
    assert_equal "admin", parsed["user_admin"]["role"]
  end

  def test_to_fixtures_all_tables
    all_fixtures = @dataset.to_fixtures
    assert_equal %w[users posts].sort, all_fixtures.keys.sort
    assert_includes all_fixtures["posts"], "title: First"
  end

  def test_write_fixtures
    Dir.mktmpdir do |dir|
      written = @dataset.write_fixtures!(dir)
      assert_equal 2, written.size

      users_file = File.join(dir, "users.yml")
      posts_file = File.join(dir, "posts.yml")

      assert File.exist?(users_file)
      assert File.exist?(posts_file)

      users_content = YAML.safe_load(File.read(users_file))
      assert_equal "admin", users_content["user_admin"]["role"]
    end
  end
end

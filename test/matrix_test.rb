# frozen_string_literal: true

require "test_helper"

class MatrixTest < Minitest::Test
  def test_empty_matrix_produces_single_empty_combination
    matrix = Astroturf::Matrix.new({})
    assert_equal [{}], matrix.combinations
    assert_equal 1, matrix.size
    refute matrix.empty?
  end

  def test_nil_dimensions_defaults_to_empty
    matrix = Astroturf::Matrix.new(nil)
    assert_equal [{}], matrix.combinations
    assert_equal 1, matrix.size
  end

  def test_single_dimension
    matrix = Astroturf::Matrix.new(role: %w[admin member])
    expected = [
      { "role" => "admin" },
      { "role" => "member" }
    ]
    assert_equal expected, matrix.combinations
    assert_equal 2, matrix.size
  end

  def test_cartesian_product_of_multiple_dimensions
    matrix = Astroturf::Matrix.new(
      role: %w[admin member],
      active: [true, false]
    )

    expected = [
      { "role" => "admin", "active" => true },
      { "role" => "admin", "active" => false },
      { "role" => "member", "active" => true },
      { "role" => "member", "active" => false }
    ]
    assert_equal expected, matrix.combinations
    assert_equal 4, matrix.size
  end

  def test_supports_ranges
    matrix = Astroturf::Matrix.new(level: 1..3)
    expected = [
      { "level" => 1 },
      { "level" => 2 },
      { "level" => 3 }
    ]
    assert_equal expected, matrix.combinations
    assert_equal 3, matrix.size
  end

  def test_single_scalar_values_are_wrapped
    matrix = Astroturf::Matrix.new(singleton: "val")
    assert_equal [{ "singleton" => "val" }], matrix.combinations
  end

  def test_empty_dimension_results_in_zero_combinations
    matrix = Astroturf::Matrix.new(role: [])
    assert_equal [], matrix.combinations
    assert_equal 0, matrix.size
    assert matrix.empty?
  end

  def test_invalid_dimensions_raises_error
    assert_raises(Astroturf::InvalidMatrixError) do
      Astroturf::Matrix.new("invalid")
    end
  end
end

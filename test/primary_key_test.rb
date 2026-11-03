# frozen_string_literal: true

require "test_helper"

class PrimaryKeyTest < Minitest::Test
  UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i.freeze

  def test_integer_sequence_default
    pk = Astroturf::PrimaryKey.build(:integer)
    assert_equal 1, pk.next_id
    assert_equal 2, pk.next_id
    assert_equal 3, pk.next_id

    pk.reset!
    assert_equal 1, pk.next_id
  end

  def test_integer_sequence_custom_start_and_step
    pk = Astroturf::PrimaryKey.build(type: :integer, start_at: 100, step: 10)
    assert_equal 100, pk.next_id
    assert_equal 110, pk.next_id
  end

  def test_uuid_generation_is_deterministic_for_label
    pk1 = Astroturf::PrimaryKey.build(:uuid)
    pk2 = Astroturf::PrimaryKey.build(:uuid)

    id1 = pk1.next_id("user_admin_active")
    id2 = pk2.next_id("user_admin_active")

    assert_match UUID_REGEX, id1
    assert_equal id1, id2
  end

  def test_uuid_different_labels_generate_different_ids
    pk = Astroturf::PrimaryKey.build(:uuid)
    id1 = pk.next_id("user_admin")
    id2 = pk.next_id("user_member")

    refute_equal id1, id2
  end

  def test_custom_callable_pk
    counter = 0
    pk = Astroturf::PrimaryKey.build(lambda { |label| "custom_#{label}_#{counter += 1}" })

    assert_equal "custom_item_1", pk.next_id("item")
    assert_equal "custom_item_2", pk.next_id("item")
  end

  def test_unsupported_strategy_raises_error
    assert_raises(Astroturf::UnknownPrimaryKeyStrategyError) do
      Astroturf::PrimaryKey.build(type: :unknown_type)
    end
  end
end

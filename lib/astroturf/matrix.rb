# frozen_string_literal: true

require_relative "errors"

module Astroturf
  class Matrix
    attr_reader :dimensions

    def self.combinations(dimensions)
      new(dimensions).combinations
    end

    def initialize(dimensions = {})
      @dimensions = normalize_dimensions(dimensions || {})
    end

    def combinations
      return [{}] if @dimensions.empty?

      keys = @dimensions.keys
      value_arrays = @dimensions.values

      return [] if value_arrays.any?(&:empty?)

      value_arrays.first.product(*value_arrays[1..-1]).map do |tuple|
        keys.zip(tuple).to_h
      end
    end

    def size
      return 1 if @dimensions.empty?
      return 0 if @dimensions.values.any?(&:empty?)

      @dimensions.values.map(&:size).inject(1, :*)
    end
    alias_method :count, :size

    def empty?
      size.zero?
    end

    private

    def normalize_dimensions(raw_dimensions)
      raise InvalidMatrixError, "Matrix dimensions must be a Hash" unless raw_dimensions.is_a?(Hash)

      raw_dimensions.each_with_object({}) do |(key, values), hash|
        hash[key.to_s] = case values
                         when Range
                           values.to_a
                         when Array
                           values
                         else
                           [values]
                         end
      end
    end
  end
end

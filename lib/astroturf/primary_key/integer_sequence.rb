# frozen_string_literal: true

module Astroturf
  module PrimaryKey
    class IntegerSequence
      attr_reader :current, :start_at, :step

      def initialize(start_at: 1, step: 1)
        @start_at = start_at
        @step = step
        @current = start_at
      end

      def next_id(_label = nil, _context = {})
        val = @current
        @current += @step
        val
      end

      def reset!
        @current = @start_at
      end
    end
  end
end

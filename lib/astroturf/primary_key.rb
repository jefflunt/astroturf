# frozen_string_literal: true

require_relative "primary_key/integer_sequence"
require_relative "primary_key/uuid"
require_relative "errors"

module Astroturf
  module PrimaryKey
    def self.build(spec = :integer)
      case spec
      when :integer, "integer", nil
        IntegerSequence.new
      when :uuid, "uuid"
        Uuid.new
      when Hash
        build_from_hash(spec)
      else
        if spec.respond_to?(:next_id)
          spec
        elsif spec.respond_to?(:call)
          CallableAdapter.new(spec)
        else
          raise UnknownPrimaryKeyStrategyError, "Unsupported primary key strategy: #{spec.inspect}"
        end
      end
    end

    def self.build_from_hash(hash)
      strategy = (hash[:type] || hash["type"] || :integer).to_s
      case strategy
      when "integer"
        start_at = hash[:start_at] || hash["start_at"] || 1
        step = hash[:step] || hash["step"] || 1
        IntegerSequence.new(start_at: start_at.to_i, step: step.to_i)
      when "uuid"
        namespace = hash[:namespace] || hash["namespace"] || Uuid::DEFAULT_NAMESPACE
        Uuid.new(namespace: namespace.to_s)
      else
        raise UnknownPrimaryKeyStrategyError, "Unsupported primary key strategy: #{strategy.inspect}"
      end
    end

    class CallableAdapter
      def initialize(callable)
        @callable = callable
      end

      def next_id(label = nil, context = {})
        if @callable.arity == 0
          @callable.call
        elsif @callable.arity == 1
          @callable.call(label)
        else
          @callable.call(label, context)
        end
      end

      def reset!
        @callable.reset! if @callable.respond_to?(:reset!)
      end
    end
  end
end

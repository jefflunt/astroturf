# frozen_string_literal: true

require_relative "matrix"
require_relative "primary_key"
require_relative "inflector"
require_relative "errors"

module Astroturf
  class Definition
    attr_reader :name, :matrix, :defaults, :pk_spec, :associations, :options

    def self.from_hash(hash)
      raise ConfigurationError, "Astroturf definition must be a Hash" unless hash.is_a?(Hash)

      hash.map do |entity_name, config|
        new(entity_name, config || {})
      end
    end

    def initialize(name, config = {})
      @name = name.to_s
      @options = config || {}
      @matrix = Matrix.new(config[:matrix] || config["matrix"] || {})
      @defaults = config[:defaults] || config["defaults"] || {}
      @pk_spec = config[:primary_key] || config["primary_key"] || :integer
      @associations = parse_associations(config)
    end

    def singular_name
      Inflector.singularize(@name)
    end

    def table_name
      @options[:table_name] || @options["table_name"] || Inflector.tableize(@name)
    end

    def foreign_key_name
      @options[:foreign_key] || @options["foreign_key"] || "#{singular_name}_id"
    end

    private

    def parse_associations(config)
      associations = []

      # Parse has_many
      raw_has_many = config[:has_many] || config["has_many"] || {}
      raw_has_many.each do |assoc_name, assoc_config|
        associations << build_association(:has_many, assoc_name, assoc_config)
      end

      # Parse has_one
      raw_has_one = config[:has_one] || config["has_one"] || {}
      raw_has_one.each do |assoc_name, assoc_config|
        associations << build_association(:has_one, assoc_name, assoc_config)
      end

      associations
    end

    def build_association(type, assoc_name, assoc_config)
      assoc_config ||= {}
      mode = (assoc_config[:mode] || assoc_config["mode"] || :combinations).to_sym
      count = assoc_config[:count] || assoc_config["count"]
      foreign_key = assoc_config[:foreign_key] || assoc_config["foreign_key"]

      Association.new(
        type: type,
        name: assoc_name.to_s,
        definition: Definition.new(assoc_name, assoc_config),
        mode: mode,
        count: count ? count.to_i : nil,
        foreign_key: foreign_key
      )
    end
  end

  class Association
    attr_reader :type, :name, :definition, :mode, :count, :foreign_key

    def initialize(type:, name:, definition:, mode: :combinations, count: nil, foreign_key: nil)
      @type = type
      @name = name
      @definition = definition
      @mode = mode
      @count = count
      @foreign_key = foreign_key
    end

    def has_many?
      @type == :has_many
    end

    def has_one?
      @type == :has_one
    end
  end
end

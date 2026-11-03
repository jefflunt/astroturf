# frozen_string_literal: true

require "yaml"
require "date"
require "time"
require_relative "astroturf/version"
require_relative "astroturf/errors"
require_relative "astroturf/matrix"
require_relative "astroturf/primary_key"
require_relative "astroturf/labeler"
require_relative "astroturf/definition"
require_relative "astroturf/dataset"
require_relative "astroturf/generator"

module Astroturf
  def self.load_file(path)
    content = File.read(path)
    load(content)
  end

  def self.load(yaml_or_hash)
    hash = case yaml_or_hash
           when String
             YAML.safe_load(yaml_or_hash, permitted_classes: [Date, Time, Symbol], aliases: true)
           when Hash
             yaml_or_hash
           else
             raise ConfigurationError, "Expected YAML string or Hash, got #{yaml_or_hash.class}"
           end

    definitions = Definition.from_hash(hash)
    Generator.generate(definitions)
  end

  class << self
    alias_method :generate, :load
    alias_method :build, :load
  end
end

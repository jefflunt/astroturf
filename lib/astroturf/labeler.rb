# frozen_string_literal: true

module Astroturf
  class Labeler
    def self.generate(entity_name, coordinates = {}, parent_label: nil, sequence: nil)
      new.generate(entity_name, coordinates, parent_label: parent_label, sequence: sequence)
    end

    def generate(entity_name, coordinates = {}, parent_label: nil, sequence: nil)
      parts = []
      parts << sanitize(parent_label) if parent_label && !parent_label.empty?
      parts << sanitize(entity_name)

      if coordinates && !coordinates.empty?
        coordinates.each do |_key, val|
          parts << sanitize(format_value(val))
        end
      end

      parts << sequence.to_s if sequence

      parts.reject(&:empty?).join("_")
    end

    def sanitize(value)
      str = value.to_s.strip
      # Replace spaces, hyphens, and non-alphanumeric chars with underscore
      str = str.gsub(/[^a-zA-Z0-9]+/, "_")
      # Collapse multiple underscores
      str = str.gsub(/_+/, "_")
      # Strip leading/trailing underscores
      str = str.gsub(/\A_+|_+\z/, "")
      str.downcase
    end

    private

    def format_value(val)
      case val
      when nil
        "nil"
      when true
        "true"
      when false
        "false"
      else
        val.to_s
      end
    end
  end
end

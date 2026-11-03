# frozen_string_literal: true

module Astroturf
  module Inflector
    PLURAL_TO_SINGULAR = [
      [/(quiz)zes$/i, '\1'],
      [/(matr)ices$/i, '\1ix'],
      [/(vert|ind)ices$/i, '\1ex'],
      [/^(ox)en$/i, '\1'],
      [/(alias|status)es$/i, '\1'],
      [/(octop|vir)i$/i, '\1us'],
      [/(cris|ax|test)es$/i, '\1is'],
      [/(shoe)s$/i, '\1'],
      [/(o)es$/i, '\1'],
      [/(bus)es$/i, '\1'],
      [/([m|l])ice$/i, '\1ouse'],
      [/(x|ch|ss|sh)es$/i, '\1'],
      [/(m)ovies$/i, '\1ovie'],
      [/(s)eries$/i, '\1eries'],
      [/([^aeiouy]|qu)ies$/i, '\1y'],
      [/([lr])ves$/i, '\1f'],
      [/(tive)s$/i, '\1'],
      [/(hive)s$/i, '\1'],
      [/(li|wi|kni)ves$/i, '\1fe'],
      [/(shea|loa|lea|thie)ves$/i, '\1f'],
      [/(^analy)ses$/i, '\1sis'],
      [/((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$/i, '\1\2sis'],
      [/([ti])a$/i, '\1um'],
      [/(n)ews$/i, '\1ews'],
      [/(h|j|k|l|m|n|p|q|r|s|t|v|w|x|z)zes$/i, '\1'],
      [/s$/i, ""]
    ].freeze

    SINGULAR_TO_PLURAL = [
      [/(quiz)$/i, '\1zes'],
      [/^(ox)$/i, '\1en'],
      [/([m|l])ouse$/i, '\1ice'],
      [/(matr|vert|ind)ix|ex$/i, '\1ices'],
      [/(x|ch|ss|sh)$/i, '\1es'],
      [/([^aeiouy]|qu)y$/i, '\1ies'],
      [/(hive)$/i, '\1s'],
      [/(?:([^f])fe|([lr])f)$/i, '\1\2ves'],
      [/sis$/i, "ses"],
      [/([ti])um$/i, '\1a'],
      [/(buffal|tomat)o$/i, '\1oes'],
      [/(bu)s$/i, '\1ses'],
      [/(alias|status)$/i, '\1es'],
      [/(octop|vir)us$/i, '\1i'],
      [/(ax|test)is$/i, '\1es'],
      [/s$/i, "s"],
      [/$/i, "s"]
    ].freeze

    IRREGULAR = {
      "person" => "people",
      "man" => "men",
      "child" => "children",
      "sex" => "sexes",
      "move" => "moves",
      "zombie" => "zombies"
    }.freeze

    def self.singularize(word)
      str = word.to_s
      return str if str.empty?

      IRREGULAR.each do |singular, plural|
        return singular.dup if str.downcase == plural
      end

      PLURAL_TO_SINGULAR.each do |rule, replacement|
        if str =~ rule
          return str.sub(rule, replacement)
        end
      end

      str
    end

    def self.pluralize(word)
      str = word.to_s
      return str if str.empty?

      IRREGULAR.each do |singular, plural|
        return plural.dup if str.downcase == singular
      end

      SINGULAR_TO_PLURAL.each do |rule, replacement|
        if str =~ rule
          return str.sub(rule, replacement)
        end
      end

      "#{str}s"
    end

    def self.tableize(word)
      pluralize(underscore(word))
    end

    def self.underscore(word)
      word.to_s
          .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
    end
  end
end

# frozen_string_literal: true

require "fileutils"
require "yaml"

module Astroturf
  class Dataset
    attr_reader :tables

    def initialize(tables = {})
      @tables = tables
    end

    def to_h
      @tables
    end

    def [](table_name)
      @tables[table_name.to_s] || {}
    end

    def table_names
      @tables.keys
    end

    def records(table_name)
      self[table_name].values
    end

    def total_records
      @tables.values.map(&:size).sum
    end

    def to_fixtures(table_name = nil)
      if table_name
        data = self[table_name]
        data.empty? ? "{}\n" : YAML.dump(data)
      else
        @tables.each_with_object({}) do |(tbl, data), hash|
          hash[tbl] = data.empty? ? "{}\n" : YAML.dump(data)
        end
      end
    end

    def write_fixtures!(dir_path)
      FileUtils.mkdir_p(dir_path)

      written_files = []
      @tables.each do |tbl, data|
        file_path = File.join(dir_path, "#{tbl}.yml")
        File.write(file_path, data.empty? ? "{}\n" : YAML.dump(data))
        written_files << file_path
      end
      written_files
    end
  end
end

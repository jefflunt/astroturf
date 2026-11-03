# frozen_string_literal: true

require_relative "dataset"
require_relative "labeler"
require_relative "primary_key"

module Astroturf
  class Generator
    def self.generate(definitions)
      new(definitions).generate
    end

    def initialize(definitions)
      @definitions = Array(definitions)
      @tables = Hash.new { |h, k| h[k] = {} }
      @pk_generators = {}
    end

    def generate
      @definitions.each do |definition|
        generate_root(definition)
      end

      Dataset.new(@tables)
    end

    private

    def pk_generator_for(definition)
      @pk_generators[definition.table_name] ||= PrimaryKey.build(definition.pk_spec)
    end

    def generate_root(definition)
      combos = definition.matrix.combinations
      pk_gen = pk_generator_for(definition)

      combos.each_with_index do |combo, index|
        label = Labeler.generate(definition.singular_name, combo)
        pk = pk_gen.next_id(label, combo)

        attributes = build_attributes(
          definition: definition,
          combo: combo,
          label: label,
          pk: pk,
          sequence: index + 1
        )

        @tables[definition.table_name][label] = attributes

        generate_associations(definition, attributes, label, pk)
      end
    end

    def generate_associations(definition, parent_attrs, parent_label, parent_pk)
      definition.associations.each do |assoc|
        assoc_def = assoc.definition
        pk_gen = pk_generator_for(assoc_def)
        fk_name = assoc.foreign_key || definition.foreign_key_name
        child_name = assoc_def.singular_name

        if assoc.has_one?
          combo = assoc_def.matrix.combinations.first || {}
          label = Labeler.generate(child_name, combo, parent_label: parent_label)
          pk = pk_gen.next_id(label, combo)

          child_attrs = build_attributes(
            definition: assoc_def,
            combo: combo,
            label: label,
            pk: pk,
            parent_attrs: parent_attrs,
            parent_label: parent_label,
            parent_pk: parent_pk,
            foreign_key_name: fk_name,
            sequence: 1
          )

          @tables[assoc_def.table_name][label] = child_attrs
          generate_associations(assoc_def, child_attrs, label, pk)

        elsif assoc.has_many?
          combos = assoc_def.matrix.combinations

          if assoc.mode == :count && assoc.count
            combos_to_generate = if combos.empty?
                                   Array.new(assoc.count) { {} }
                                 else
                                   combos.cycle.take(assoc.count)
                                 end

            combos_to_generate.each_with_index do |combo, idx|
              seq = idx + 1
              label = Labeler.generate(child_name, combo, parent_label: parent_label, sequence: seq)
              pk = pk_gen.next_id(label, combo)

              child_attrs = build_attributes(
                definition: assoc_def,
                combo: combo,
                label: label,
                pk: pk,
                parent_attrs: parent_attrs,
                parent_label: parent_label,
                parent_pk: parent_pk,
                foreign_key_name: fk_name,
                sequence: seq
              )

              @tables[assoc_def.table_name][label] = child_attrs
              generate_associations(assoc_def, child_attrs, label, pk)
            end
          else
            # :combinations mode (Default)
            combos.each_with_index do |combo, idx|
              label = Labeler.generate(child_name, combo, parent_label: parent_label)
              pk = pk_gen.next_id(label, combo)

              child_attrs = build_attributes(
                definition: assoc_def,
                combo: combo,
                label: label,
                pk: pk,
                parent_attrs: parent_attrs,
                parent_label: parent_label,
                parent_pk: parent_pk,
                foreign_key_name: fk_name,
                sequence: idx + 1
              )

              @tables[assoc_def.table_name][label] = child_attrs
              generate_associations(assoc_def, child_attrs, label, pk)
            end
          end
        end
      end
    end

    def build_attributes(definition:, combo:, label:, pk:, sequence:, parent_attrs: nil, parent_label: nil, parent_pk: nil, foreign_key_name: nil)
      context = {
        "id" => pk,
        "label" => label,
        "seq" => sequence
      }

      if parent_label
        context["parent.label"] = parent_label
        context["parent.id"] = parent_pk
      end

      # Add combo attributes into context
      combo.each do |k, v|
        context[k.to_s] = v
      end

      attributes = { "id" => pk }
      attributes[foreign_key_name] = parent_pk if foreign_key_name && parent_pk

      # Merge defaults with interpolation
      definition.defaults.each do |key, val|
        attributes[key.to_s] = resolve_value(val, context)
      end

      # Matrix values override defaults
      combo.each do |key, val|
        attributes[key.to_s] = val
      end

      attributes
    end

    def resolve_value(val, context)
      case val
      when String
        interpolate(val, context)
      when Proc
        val.arity == 0 ? val.call : val.call(context)
      else
        val
      end
    end

    def interpolate(template, context)
      template.gsub(/%\{([^}]+)\}/) do
        key = Regexp.last_match(1)
        if context.key?(key)
          context[key].to_s
        else
          "%{#{key}}"
        end
      end
    end
  end
end

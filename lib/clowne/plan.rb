# frozen_string_literal: true

module Clowne
  class Plan # :nodoc: all
    def initialize(registry)
      @registry = registry
      @data = {}
    end

    def add(type, declaration)
      data[type] = [] unless data.key?(type)
      data[type] << declaration
    end

    def add_to(type, id, declaration)
      data[type] = {} unless data.key?(type)
      data[type][id] = declaration
    end

    def set(type, declaration)
      data[type] = declaration
    end

    def get(type)
      data[type]
    end

    def remove(type)
      data.delete(type)
    end

    def remove_from(type, id)
      return unless data[type]
      data[type].delete(id)
    end

    def declarations
      registry.actions.flat_map do |type|
        value = data[type]
        next if value.nil?
        value = value.values if value.is_a?(Hash)
        value = Array(value)
        value.map { |v| [type, v] }
      end.compact
    end

    def dup
      self.class.new(registry).tap do |duped|
        data.each do |k, v|
          duped.set(k, v.dup)
        end
      end
    end

    private

    attr_reader :data, :registry
  end
end

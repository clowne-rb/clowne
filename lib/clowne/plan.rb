# frozen_string_literal: true

module Clowne
  class Plan # :nodoc: all
    class Registry
      attr_reader :actions

      def initialize
        @actions = []
      end

      def insert_after(after, action)
        validate_uniq!(action)

        after_index = actions.find_index(after)

        raise "Plan action not found: #{after}" if after_index.nil?

        actions.insert(after_index + 1, action)
      end

      def insert_before(before, action)
        validate_uniq!(action)

        before_index = actions.find_index(before)

        raise "Plan action not found: #{before}" if before_index.nil?

        actions.insert(before_index, action)
      end

      def append(action)
        validate_uniq!(action)
        actions.push action
      end

      def prepend(action)
        validate_uniq!(action)
        actions.unshift action
      end

      private

      def validate_uniq!(action)
        raise "Plan action already registered: #{action}" if actions.include?(action)
      end
    end

    class << self
      attr_reader :registry

      protected

      attr_writer :registry
    end

    self.registry = Registry.new

    def initialize(registry = self.class.registry)
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

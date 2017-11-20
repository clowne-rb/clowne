# frozen_string_literal: true

module Clowne
  class Plan # :nodoc: all
    def initialize
      # By default, we store actions in arrays
      @data = Hash.new { |h, k| h[k] = [] }
    end

    def add(type, declaration)
      data[type] << declaration
    end

    def add_to(type, id, declaration)
      data[type] = {} unless data.key?(type)
      data[type][id] = declaration
    end

    def set(type, declaration)
      data[type] = declaration
    end

    def remove(type)
      data.delete(type)
    end

    def remove_from(type, id)
      return unless data[type]
      data[type].delete(id)
    end

    def declarations
      data.flat_map do |(type, value)|
        value = value.values if value.is_a?(Hash)
        value.map { |v| [type, v] }
      end
    end

    private

    attr_reader :data
  end
end

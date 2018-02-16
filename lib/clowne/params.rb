# frozen_string_literal: true

module Clowne
  class Params # :nodoc: all
    class BaseProxy
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def permit(_params)
        raise NotImplementedError
      end
    end

    class PassProxy < BaseProxy
      def permit(params)
        params
      end
    end

    class NullProxy < BaseProxy
      def permit(_params)
        {}
      end
    end

    class BlockProxy < BaseProxy
      def permit(params)
        value.call(params)
      end
    end

    class KeyProxy < BaseProxy
      def permit(params)
        nested_params = params.fetch(value)
        return nested_params if nested_params.is_a?(Hash)

        raise KeyError, "value by key '#{value}' must be a Hash"
      end
    end

    class << self
      def proxy(value)
        if value == true
          PassProxy
        elsif value.nil? || value == false
          NullProxy
        elsif value.is_a?(Proc)
          BlockProxy
        else
          KeyProxy
        end.new(value)
      end
    end
  end
end

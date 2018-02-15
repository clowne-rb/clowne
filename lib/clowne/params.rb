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
        params.fetch(value)
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

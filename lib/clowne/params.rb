# frozen_string_literal: true

require 'clowne/ext/lambda_as_proc'

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
      def permit(params:, **)
        params
      end
    end

    class NullProxy < BaseProxy
      def permit(_params)
        {}
      end
    end

    class BlockProxy < BaseProxy
      using Clowne::Ext::LambdaAsProc

      def permit(params:, parent:)
        value.to_proc.call(params, parent)
      end
    end

    class KeyProxy < BaseProxy
      def permit(params:, **)
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

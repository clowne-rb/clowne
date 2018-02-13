# frozen_string_literal: true

module Clowne
  class Params # :nodoc: all
    class BaseProxy
      attr_reader :options

      def initialize(options)
        @options = options
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
        params.instance_eval(&options)
      end
    end

    class KeyProxy < BaseProxy
      def permit(params)
        params.fetch(options)
      end
    end

    class << self
      def proxy(options)
        if options == true
          PassProxy
        elsif options.nil? || options == false
          NullProxy
        elsif options.is_a?(Proc)
          BlockProxy
        else
          KeyProxy
        end.new(options)
      end
    end
  end
end

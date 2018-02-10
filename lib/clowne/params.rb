# frozen_string_literal: true

module Clowne
  class Params # :nodoc: all
    class BaseFilter
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def permit(_params)
        raise NotImplementedError
      end
    end

    class AllowFilter < BaseFilter
      def permit(params)
        params
      end
    end

    class DenyFilter < BaseFilter
      def permit(_params)
        {}
      end
    end

    class ByBlockFilter < BaseFilter
      def permit(params)
        params.instance_eval(&options)
      end
    end

    class ByKeyFilter < BaseFilter
      def permit(params)
        params.fetch(options)
      end
    end

    class << self
      def filter(options)
        if options == true
          AllowFilter
        elsif options.nil? || options == false
          DenyFilter
        elsif options.is_a?(Proc)
          ByBlockFilter
        else
          ByKeyFilter
        end.new(options)
      end
    end
  end
end

# frozen_string_literal: true

module Clowne
  class Params # :nodoc: all
    class BaseParams
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def permit(params)
        raise NotImplementedError
      end
    end

    class AllowParams < BaseParams
      def permit(params)
        params
      end
    end

    class DenyParams < BaseParams
      def permit(_params)
        {}
      end
    end

    class ByBlockParams < BaseParams
      def permit(params)
        params.instance_eval(&options)
      end
    end

    class ByKeyParams < BaseParams
      def permit(params)
        params.fetch(options)
      end
    end

    class << self
      def build(options)
        if options == true
          AllowParams
        elsif options.nil? || options == false
          DenyParams
        elsif options.is_a?(Proc)
          ByBlockParams
        else
          ByKeyParams
        end.new(options)
      end
    end
  end
end

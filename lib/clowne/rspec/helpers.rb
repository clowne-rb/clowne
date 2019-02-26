# frozen_string_literal: true

module Clowne
  module RSpec
    module Helpers # :nodoc: all
      attr_reader :cloner

      def with_traits(*traits)
        @traits = traits
        self
      end

      def matches?(actual)
        raise ArgumentError, non_cloner_message unless actual <= ::Clowne::Cloner

        @cloner = actual
        super
      end

      def plan
        @plan ||=
          if @traits.nil?
            cloner.default_plan
          else
            cloner.plan_with_traits(@traits)
          end
      end

      def non_cloner_message
        'expected a cloner to be passed to `expect(...)`, ' \
        "but got #{actual_formatted}"
      end
    end
  end
end

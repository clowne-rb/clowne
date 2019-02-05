# frozen_string_literal: true

module Clowne
  module Utils # :nodoc: all
    class Options
      INTERNAL_KEYS = %i[adapter traits clowne_only_actions mapping only].freeze

      def initialize(options)
        @options = options
      end

      def traits
        @_traits ||= Array(options[:traits])
      end

      def only
        options[:clowne_only_actions]
      end

      def mapper
        options[:mapper]
      end

      def adapter
        options[:adapter]
      end

      def params
        options.dup.tap do |o|
          INTERNAL_KEYS.each { |key| o.delete(key) }
        end
      end

      private

      attr_reader :options
    end
  end
end

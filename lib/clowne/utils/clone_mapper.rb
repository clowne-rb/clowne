# frozen_string_literal: true

require 'clowne/ext/record_key'

module Clowne
  module Utils
    class CloneMapper # :nodoc: all
      def initialize
        @store = {}
      end

      def add(origin, clone)
        @store[origin] ||= clone
      end

      def clone_of(origin)
        @store[origin]
      end

      def origin_of(clone)
        origin, _clone = @store.rassoc(clone)
        origin
      end
    end
  end
end

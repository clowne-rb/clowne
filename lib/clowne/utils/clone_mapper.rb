# frozen_string_literal: true

require 'clowne/ext/record_key'

module Clowne
  module Utils
    class CloneMapper # :nodoc: all
      include Clowne::Ext::RecordKey

      def initialize
        @store = {}
      end

      def add(origin, clone)
        origin_key = key(origin)
        return @store[origin_key] if @store.key?(origin_key)

        @store[origin_key] = clone
      end

      def clone_of(record)
        @store[key(record)]
      end
    end
  end
end

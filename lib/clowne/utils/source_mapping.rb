# frozen_string_literal: true

module Clowne
  module Utils
    class SourceMapping # :nodoc: all
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

      private

      def key(record)
        id = record.respond_to?(:id) ? record.id : record.__id__
        [record.class.name, id].join('#')
      end
    end
  end
end

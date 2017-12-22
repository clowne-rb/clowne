# frozen_string_literal: true

module Clowne
  module Adapters
    class Registry # :nodoc: all
      attr_reader :actions, :mapping

      def initialize
        @actions = []
        @mapping = {}
      end

      def insert_after(after, action)
        validate_uniq!(action)

        after_index = actions.find_index(after)

        raise "Plan action not found: #{after}" if after_index.nil?

        actions.insert(after_index + 1, action)
      end

      def insert_before(before, action)
        validate_uniq!(action)

        before_index = actions.find_index(before)

        raise "Plan action not found: #{before}" if before_index.nil?

        actions.insert(before_index, action)
      end

      def append(action)
        validate_uniq!(action)
        actions.push action
      end

      def prepend(action)
        validate_uniq!(action)
        actions.unshift action
      end

      def dup
        self.class.new.tap do |duped|
          actions.each { |act| duped.append(act) }
          duped.mapping = mapping.dup
        end
      end

      protected

      attr_writer :mapping

      private

      def validate_uniq!(action)
        raise "Plan action already registered: #{action}" if actions.include?(action)
      end
    end
  end
end

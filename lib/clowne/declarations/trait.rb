# frozen_string_literal: true

module Clowne
  module Declarations
    class Trait # :nodoc: all
      def initialize
        @blocks = []
      end

      def extend_with(block)
        @blocks << block
      end

      def compiled
        return @compiled if instance_variable_defined?(:@compiled)
        @compiled = compile
      end

      alias declarations compiled

      def dup
        self.class.new.tap do |duped|
          blocks.each { |b| duped.extend_with(b) }
        end
      end

      private

      attr_reader :blocks

      def compile
        anonymous_cloner = Class.new(Clowne::Cloner)

        blocks.each do |block|
          anonymous_cloner.instance_eval(&block)
        end

        anonymous_cloner.declarations
      end
    end
  end
end

Clowne::Declarations.add :trait do |name, &block|
  register_trait name, block
end

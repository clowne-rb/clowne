# frozen_string_literal: true

module Clowne
  module Declarations
    class AfterClone < Base # :nodoc: all
      attr_reader :block

      def initialize
        raise ArgumentError, 'Block is required for after_clone' unless block_given?

        @block = Proc.new
      end

      def compile(plan)
        plan.add(:after_clone, self)
      end
    end
  end
end

Clowne::Declarations.add :after_clone, Clowne::Declarations::AfterClone

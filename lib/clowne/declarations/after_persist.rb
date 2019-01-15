# frozen_string_literal: true

module Clowne
  module Declarations
    class AfterPersist < Base # :nodoc: all
      attr_reader :block

      def initialize
        raise ArgumentError, 'Block is required for after_persist' unless block_given?

        @block = Proc.new
      end

      def compile(plan)
        plan.add(:after_persist, self)
      end
    end
  end
end

Clowne::Declarations.add :after_persist, Clowne::Declarations::AfterPersist

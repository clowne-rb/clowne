# frozen_string_literal: true

module Clowne
  module Declarations
    class Finalize < Base # :nodoc: all
      attr_reader :block

      def initialize
        raise ArgumentError, 'Block is required for finalize' unless block_given?
        @block = Proc.new
      end

      def compile(plan)
        plan.add(:finalize, self)
      end
    end
  end
end

Clowne::Declarations.add :finalize, Clowne::Declarations::Finalize

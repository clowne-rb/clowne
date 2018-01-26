# frozen_string_literal: true

module Clowne
  module Declarations
    class InitAs # :nodoc: all
      attr_reader :block

      def initialize
        raise ArgumentError, 'Block is required for init_as' unless block_given?
        @block = Proc.new
      end

      def compile(plan)
        plan.set(:init_as, self)
      end
    end
  end
end

Clowne::Declarations.add :init_as, Clowne::Declarations::InitAs

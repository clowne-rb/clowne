# frozen_string_literal: true

module Clowne
  module Declarations
    class InitAs < Base # :nodoc: all
      attr_reader :block

      def initialize(*, &block)
        raise ArgumentError, "Block is required for init_as" unless block

        @block = block
      end

      def compile(plan)
        plan.set(:init_as, self)
      end
    end
  end
end

Clowne::Declarations.add :init_as, Clowne::Declarations::InitAs

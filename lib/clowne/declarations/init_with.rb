# frozen_string_literal: true

module Clowne
  module Declarations
    class InitWith # :nodoc: all
      attr_reader :block

      def initialize
        raise ArgumentError, 'Block is required for init_with' unless block_given?
        @block = Proc.new
      end

      def compile(plan)
        plan.set(:init_with, self)
      end
    end
  end
end

Clowne::Declarations.add :init_with, Clowne::Declarations::InitWith

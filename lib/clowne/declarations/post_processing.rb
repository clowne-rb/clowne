# frozen_string_literal: true

module Clowne
  module Declarations
    class PostProcessing < Base # :nodoc: all
      attr_reader :block

      def initialize
        raise ArgumentError, 'Block is required for post_processing' unless block_given?

        @block = Proc.new
      end

      def compile(plan)
        plan.add(:post_processing, self)
      end
    end
  end
end

Clowne::Declarations.add :post_processing, Clowne::Declarations::PostProcessing

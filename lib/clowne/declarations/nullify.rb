# frozen_string_literal: true

module Clowne
  module Declarations
    class Nullify < Base # :nodoc: all
      attr_reader :attributes

      def initialize(*attributes)
        raise ArgumentError, 'At least one attribute required' if attributes.empty?
        @attributes = attributes
      end

      def compile(plan)
        plan.add(:nullify, self)
      end
    end
  end
end

Clowne::Declarations.add :nullify, Clowne::Declarations::Nullify

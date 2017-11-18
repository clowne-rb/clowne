# frozen_string_literal: true

module Clowne
  module Declarations
    Nullify = Struct.new(:attributes)

    class Nullify # :nodoc: all
      PLAN_NAME = :nullify

      def compile(plan, _settings)
        plan.update(PLAN_NAME, accumulate(plan) || self)
      end

      private

      def accumulate(plan)
        current_nullify = plan.get(PLAN_NAME)
        return if current_nullify.nil?
        self.class.new(current_nullify.declaration.attributes + attributes)
      end
    end
  end
end

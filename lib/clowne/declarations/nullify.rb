module Clowne
  module Declarations
    class Nullify < Struct.new(:attributes)
      PLAN_NAME = :nullify

      def compile(plan, _settings)
        plan[PLAN_NAME] = accumulate(plan) || self
        plan
      end

      private

      def accumulate(plan)
        current_nullify = plan[PLAN_NAME]
        return if current_nullify.nil?
        self.class.new(current_nullify.attributes + attributes)
      end
    end
  end
end

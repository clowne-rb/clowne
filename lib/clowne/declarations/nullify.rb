module Clowne
  module Declarations
    class Nullify < Struct.new(:attributes)
      PLAN_NAME = :nullify

      def compile(plan, _settings)
        plan[PLAN_NAME] = self
        plan
      end
    end
  end
end

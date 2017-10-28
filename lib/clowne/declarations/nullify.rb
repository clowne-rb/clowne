module Clowne
  module Declarations
    class Nullify < Struct.new(:attributes)
      PLAN_NAME = :nullify

      def compile(plan, _options)
        plan[PLAN_NAME] = self
        plan
      end
    end
  end
end

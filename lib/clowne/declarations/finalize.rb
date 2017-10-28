module Clowne
  module Declarations
    class Finalize < Struct.new(:block)
      PLAN_NAME = :finalize

      def compile(plan, _options)
        plan[PLAN_NAME] = self
        plan
      end
    end
  end
end

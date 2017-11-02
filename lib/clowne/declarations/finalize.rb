module Clowne
  module Declarations
    class Finalize < Struct.new(:block)
      PLAN_NAME = :finalize

      def compile(plan, _settings)
        plan[name] = self
        plan
      end

      private

      def name
        [PLAN_NAME, __id__].join('-')
      end
    end
  end
end

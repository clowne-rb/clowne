# frozen_string_literal: true

module Clowne
  module Declarations
    class Finalize < Struct.new(:block)
      PLAN_NAME = :finalize

      def compile(plan, _settings)
        plan.add([PLAN_NAME, __id__].join('-'), self)
      end
    end
  end
end

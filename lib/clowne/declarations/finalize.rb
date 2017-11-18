# frozen_string_literal: true

module Clowne
  module Declarations
    Finalize = Struct.new(:block)

    class Finalize # :nodoc: all
      PLAN_NAME = :finalize

      def compile(plan, _settings)
        plan.add([PLAN_NAME, __id__].join('-'), self)
      end
    end
  end
end

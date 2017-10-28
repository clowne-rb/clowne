module Clowne
  class Planner
    class << self
      def compile(cloner, object, init_plan = {})
        cloner.config.config.inject(init_plan) do |plan, declaration|
          declaration.compile(plan, {object: object, adapter: cloner.adapter})
        end
      end
    end
  end
end

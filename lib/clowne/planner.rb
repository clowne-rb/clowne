module Clowne
  class Planner
    class << self
      def compile(cloner, object, options = {})
        cloner.config.config.inject({}) do |plan, declaration|
          declaration.compile(current_plan, {object: object, adapter: cloner.adapter})
        end
      end
    end
  end
end

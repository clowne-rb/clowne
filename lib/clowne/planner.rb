module Clowne
  class Planner
    class << self
      def compile(cloner, object, options = {})
        cloner.config.config.inject({}) do |plan, declaration|

          declaration.compile(plan, {object: object, adapter: cloner.adapter})
        end.values
      end
    end
  end
end

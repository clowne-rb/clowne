module Clowne
  class Planner
    class << self
      # Params:
      # +cloner+:: implementation of Clowne::Cloner
      # +object+:: cloned object (for example: ActiveRecord object)
      # +init_plan+:: Hash of init plan
      # +options+:: {for: [trait, ...]} of nothing
      def compile(cloner, object, init_plan = {}, **options)
        compile_with_tags(cloner, object, init_plan, **options).values
      end

      def compile_with_tags(cloner, object, init_plan = {}, **options)
        cloner.config.config.inject(init_plan) do |plan, declaration|
          declaration.compile(plan, {object: object, adapter: cloner.adapter, options: options})
        end
      end
    end
  end
end

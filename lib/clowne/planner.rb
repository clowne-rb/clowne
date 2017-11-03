module Clowne
  class Plan
    Step = Struct.new(:key, :declaration)

    def initialize
      @steps = []
    end

    def get(key)
      key = key.to_sym
      @steps.detect { |step| step.key == key }
    end

    def add(key, declaration)
      @steps << Step.new(key.to_sym, declaration)
      self
    end

    def update(key, declaration)
      position = @steps.index(get(key))
      if position
        @steps[position] = Step.new(key, declaration)
        self
      else
        add(key, declaration)
      end
    end

    def delete(key)
      key = key.to_sym
      @steps.reject! { |step| step.key == key }
      self
    end

    def declarations
      @steps.map(&:declaration)
    end
  end

  class Planner
    class << self
      # Params:
      # +cloner+:: implementation of Clowne::Cloner
      # +object+:: cloned object (for example: ActiveRecord object)
      # +init_plan+:: Hash of init plan
      # +options+:: {for: [trait, ...]} of nothing
      def compile(cloner, object, init_plan = Plan.new, **options)
        cloner.config.declarations.inject(init_plan) do |plan, declaration|
          declaration.compile(plan, {object: object, adapter: cloner.adapter, options: options})
        end
      end
    end
  end
end

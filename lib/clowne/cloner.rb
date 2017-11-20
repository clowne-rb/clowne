# frozen_string_literal: true

module Clowne # :nodoc: all
  class UnprocessableSourceError < StandardError; end
  class ConfigurationError < StandardError; end

  class Cloner
    extend Clowne::DSL

    class << self
      def inherited(subclass)
        subclass.adapter(adapter)
        subclass.config(Clowne::Configuration.new(config.declarations.dup))
        (@descendants ||= []) << subclass
      end

      def descendants
        @descendants || []
      end

      def call(object, **options)
        raise(UnprocessableSourceError, 'Nil is not cloneable object') if object.nil?

        traits = options.delete(:traits)

        plan = build_plan_with_traits(traits)
        adapter.clone(object, plan, traits: traits, params: options)
      end

      private

      def default_plan
        return @default_plan if instance_variable_defined?(:@default_plan)
        @default_plan = Clowne::Planner.compile(self, Clowne::Plan.new)
      end

      def build_plan_with_traits(traits)
        # Cache plans for combinations of traits
        traits_id = traits.map(&:to_s).join(':')
        return traits_plans[traits_id] if traits_plans.key?(traits_id)
        traits_plans[trait] = Clowne::Planner.compile(self, default_plan.dup, traits: traits)
      end

      def traits_plans
        return @traits_plans if instance_variable_defined?(:@traits_plans)
        @traits_plans = {}
      end
    end
  end
end

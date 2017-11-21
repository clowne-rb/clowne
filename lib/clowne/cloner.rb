# frozen_string_literal: true

require 'clowne/planner'
require 'clowne/dsl'

module Clowne # :nodoc: all
  class UnprocessableSourceError < StandardError; end
  class ConfigurationError < StandardError; end

  class Cloner
    extend Clowne::DSL

    class << self
      def inherited(subclass)
        subclass.adapter(adapter)
        subclass.declarations = declarations.dup

        return if traits.nil?

        traits.each do |name, trait|
          subclass.traits[name] = trait.dup
        end
      end

      def declarations
        return @declarations if instance_variable_defined?(:@declarations)
        @declarations = []
      end

      def traits
        return @traits if instance_variable_defined?(:@traits)
        @traits = {}
      end

      def register_trait(name, block)
        @traits ||= {}
        @traits[name] ||= Declarations::Trait.new
        @traits[name].extend_with(block)
      end

      def call(object, **options)
        raise(UnprocessableSourceError, 'Nil is not cloneable object') if object.nil?

        raise(ConfigurationError, 'Adapter is not defined') if adapter.nil?

        traits = options.delete(:traits)

        plan =
          if traits.nil? || traits.empty?
            default_plan
          else
            build_plan_with_traits(traits)
          end

        adapter.clone(object, plan, traits: traits, params: options)
      end

      protected

      attr_writer :declarations

      private

      def default_plan
        return @default_plan if instance_variable_defined?(:@default_plan)
        @default_plan = Clowne::Planner.compile(self)
      end

      def build_plan_with_traits(traits)
        # Cache plans for combinations of traits
        traits_id = traits.map(&:to_s).join(':')
        return traits_plans[traits_id] if traits_plans.key?(traits_id)
        traits_plans[trait] = Clowne::Planner.compile(
          self, init_plan: default_plan.dup, traits: traits
        )
      end

      def traits_plans
        return @traits_plans if instance_variable_defined?(:@traits_plans)
        @traits_plans = {}
      end
    end
  end
end

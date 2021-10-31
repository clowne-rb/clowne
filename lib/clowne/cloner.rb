# frozen_string_literal: true

require "clowne/planner"
require "clowne/dsl"
require "clowne/utils/options"
require "clowne/utils/params"
require "clowne/utils/operation"

module Clowne # :nodoc: all
  class UnprocessableSourceError < StandardError; end

  class ConfigurationError < StandardError; end

  class Cloner
    extend Clowne::DSL

    class << self
      def inherited(subclass)
        subclass.adapter(adapter) unless self == Clowne::Cloner
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

      def call(object, **options, &block)
        raise(UnprocessableSourceError, "Nil is not cloneable object") if object.nil?

        options = Clowne::Utils::Options.new(options)
        current_adapter = current_adapter(options.adapter)

        raise(ConfigurationError, "Adapter is not defined") if current_adapter.nil?

        plan =
          if options.traits.empty?
            default_plan(current_adapter: current_adapter)
          else
            plan_with_traits(options.traits, current_adapter: current_adapter)
          end

        plan = Clowne::Planner.enhance(plan, block) if block

        plan = Clowne::Planner.filter_declarations(plan, options.only)

        call_operation(current_adapter, object, plan, options)
      end
      # rubocop: enable Metrics/AbcSize, Metrics/MethodLength

      def partial_apply(only, *args, **hargs)
        call(*args, **hargs, clowne_only_actions: prepare_only(only))
      end

      def default_plan(current_adapter: adapter)
        return @default_plan if instance_variable_defined?(:@default_plan)

        @default_plan = Clowne::Planner.compile(current_adapter, self)
      end

      def plan_with_traits(ids, current_adapter: adapter)
        # Cache plans for combinations of traits
        traits_id = ids.map(&:to_s).join(":")
        return traits_plans[traits_id] if traits_plans.key?(traits_id)

        traits_plans[traits_id] = Clowne::Planner.compile(
          current_adapter, self, traits: ids
        )
      end

      protected

      attr_writer :declarations

      private

      def call_operation(adapter, object, plan, options)
        adapter.class.operation_class.wrap(mapper: options.mapper) do
          adapter.clone(object, plan, params: options.params)
        end
      end

      def traits_plans
        return @traits_plans if instance_variable_defined?(:@traits_plans)

        @traits_plans = {}
      end

      def prepare_only(val)
        val = Array.wrap(val)
        val.each_with_object({}) do |type, acc|
          # type is a Symbol or Hash
          if type.is_a?(Hash)
            acc.merge!(type)
          elsif type.is_a?(Symbol)
            acc[type] = nil
          end
        end
      end
    end
  end
end

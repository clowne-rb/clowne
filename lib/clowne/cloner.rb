# frozen_string_literal: true

require 'clowne/planner'
require 'clowne/dsl'
require 'clowne/utils/params'
require 'clowne/utils/operation'

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

      # rubocop: disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop: disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def call(object, **options)
        raise(UnprocessableSourceError, 'Nil is not cloneable object') if object.nil?

        raise(ConfigurationError, 'Adapter is not defined') if adapter.nil?

        traits = options.delete(:traits)

        only = options.delete(:clowne_only_actions)

        traits = Array(traits) unless traits.nil?

        plan =
          if traits.nil? || traits.empty?
            default_plan
          else
            plan_with_traits(traits)
          end

        plan = Clowne::Planner.enhance(plan, Proc.new) if block_given?

        plan = Clowne::Planner.filter_declarations(plan, only)

        with_operation { adapter.clone(object, plan, params: options) }
      end

      def partial_apply(only, *args, **hargs)
        call(*args, **hargs, clowne_only_actions: prepare_only(only))
      end

      # rubocop: enable Metrics/AbcSize, Metrics/MethodLength
      # rubocop: enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def default_plan
        return @default_plan if instance_variable_defined?(:@default_plan)
        @default_plan = Clowne::Planner.compile(self)
      end

      def plan_with_traits(ids)
        # Cache plans for combinations of traits
        traits_id = ids.map(&:to_s).join(':')
        return traits_plans[traits_id] if traits_plans.key?(traits_id)
        traits_plans[traits_id] = Clowne::Planner.compile(
          self, traits: ids
        )
      end

      protected

      attr_writer :declarations

      private

      def with_operation
        return yield unless adapter.is_a?(Clowne::Adapters::ActiveRecord) # TODO: use Operation for all adapters

        Clowne::Utils::Operation.wrap do
          yield
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

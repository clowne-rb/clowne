# frozen_string_literal: true

require "clowne/utils/plan"

module Clowne
  class Planner # :nodoc: all
    class << self
      # Compile plan for cloner with traits
      def compile(adapter, cloner, traits: nil)
        declarations = cloner.declarations.dup

        declarations += compile_traits(cloner, traits) unless traits.nil?

        declarations.each_with_object(
          Utils::Plan.new(adapter.registry)
        ) do |declaration, plan|
          declaration.compile(plan)
        end
      end

      # Extend previously compiled plan with an arbitrary block
      # NOTE: It doesn't modify the plan itself but return a copy
      def enhance(plan, block)
        trait = Clowne::Declarations::Trait.new.tap { |t| t.extend_with(block) }

        trait.compiled.each_with_object(plan.dup) do |declaration, new_plan|
          declaration.compile(new_plan)
        end
      end

      def filter_declarations(plan, only)
        return plan if only.nil?

        plan.dup.tap do |new_plan|
          new_plan.declarations.reject! do |(type, declaration)|
            !only.key?(type) || !declaration.matches?(only[type])
          end
        end
      end

      private

      def compile_traits(cloner, traits)
        traits.map do |id|
          trait = cloner.traits[id]
          raise ConfigurationError, "Trait not found: #{id}" if trait.nil?

          trait.compiled
        end.flatten
      end
    end
  end
end

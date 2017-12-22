# frozen_string_literal: true

require 'clowne/plan'

module Clowne
  class Planner # :nodoc: all
    class << self
      # Params:
      # +cloner+:: Cloner object
      # +init_plan+:: Init plan
      # +traits+:: List of traits if any
      def compile(cloner, traits: nil)
        declarations = cloner.declarations.dup

        declarations += compile_traits(cloner, traits) unless traits.nil?

        declarations.each_with_object(Plan.new(cloner.adapter.registry)) do |declaration, plan|
          declaration.compile(plan)
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

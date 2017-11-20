# frozen_string_literal: true

module Clowne
  class Planner # :nodoc: all
    class << self
      # Params:
      # +cloner+:: implementation of Clowne::Cloner
      # +object+:: cloned object (for example: ActiveRecord object)
      # +init_plan+:: Init plan
      # +traits+:: List of traits if any
      def compile(cloner, init_plan: Plan.new, traits: nil)
        raise(Clowne::ConfigurationError, 'Adapter is not defined') unless cloner.adapter

        cloner.config.declarations.each_with_object(init_plan) do |plan, declaration|
          declaration.compile(plan, cloner: cloner, adapter: cloner.adapter)
        end
      end
    end
  end
end

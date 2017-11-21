# frozen_string_literal: true

require 'clowne/plan'

module Clowne
  class Planner # :nodoc: all
    class << self
      # Params:
      # +declarations+:: List of declarations
      # +init_plan+:: Init plan
      # +traits+:: List of traits if any
      def compile(declarations, init_plan: Plan.new, traits: nil)
        declarations.each_with_object(init_plan) do |declaration, plan|
          declaration.compile(plan)
        end
      end
    end
  end
end

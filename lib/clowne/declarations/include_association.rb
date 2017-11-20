# frozen_string_literal: true

module Clowne
  module Declarations
    class IncludeAssociation # :nodoc: all
      attr_accessor :name, :scope, :options

      def initialize(name, scope = nil, options = {})
        @name = name.to_sym
        @scope = scope
        @options = options
      end

      def compile(plan, _settings)
        # Clear `#include_all`
        plan.remove(:all_associations)
        plan.add_to(:association, name, self)
      end

      def clone_with
        options[:clone_with]
      end
    end
  end
end

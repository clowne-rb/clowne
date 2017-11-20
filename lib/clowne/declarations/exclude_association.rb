# frozen_string_literal: true

module Clowne
  module Declarations
    class ExcludeAssociation # :nodoc: all
      attr_accessor :name

      def initialize(name)
        @name = name.to_sym
      end

      def compile(plan, _settings)
        plan.remove_from(:association, name)

        # update all_associations plan
        all_associations = plan.get(:all_associations)
        return if all_associations.nil?
        all_associations.except! name
      end
    end
  end
end

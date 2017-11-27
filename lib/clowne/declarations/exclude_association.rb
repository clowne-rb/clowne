# frozen_string_literal: true

module Clowne
  module Declarations
    class ExcludeAssociation # :nodoc: all
      attr_accessor :name

      def initialize(name)
        @name = name.to_sym
      end

      def compile(plan)
        plan.remove_from(:association, name)

        # update all_associations plan
        all_associations = plan.get(:all_associations)
        return if all_associations.nil?
        all_associations.except! name
      end
    end
  end
end

Clowne::Declarations.add :exclude_association, Clowne::Declarations::ExcludeAssociation
Clowne::Declarations.add :exclude_associations do |*names|
  names.each do |name|
    declarations.push Clowne::Declarations::ExcludeAssociation.new(name)
  end
end

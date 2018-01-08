# frozen_string_literal: true

require 'clowne/ext/string_constantize'

module Clowne
  module Declarations
    class IncludeAssociation # :nodoc: all
      using Clowne::Ext::StringConstantize

      attr_accessor :name, :scope, :options

      def initialize(name, scope = nil, **options)
        @name = name.to_sym
        @scope = scope
        @options = options
      end

      def compile(plan)
        plan.add_to(:association, name, self)
      end

      def clone_with
        return @clone_with if instance_variable_defined?(:@clone_with)
        @clone_with =
          case options[:clone_with]
          when String, Symbol
            options[:clone_with].to_s.constantize
          else
            options[:clone_with]
          end
      end

      def traits
        options[:traits]
      end
    end
  end
end

Clowne::Declarations.add :include_association, Clowne::Declarations::IncludeAssociation
Clowne::Declarations.add :include_associations do |*names|
  names.each do |name|
    declarations.push Clowne::Declarations::IncludeAssociation.new(name)
  end
end

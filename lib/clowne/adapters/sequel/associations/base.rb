# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class Base
          # Params:
          # +reflection+:: Association eflection object
          # +source+:: Instance of cloned object (ex: User.new(posts: posts))
          # +declaration+:: = Relation description
          #                   (ex: Clowne::Declarations::IncludeAssociation.new(:posts))
          # +params+:: = Instance of Hash
          def initialize(reflection, source, declaration, params)
            @source = source
            @scope = declaration.scope
            @clone_with = declaration.clone_with
            @params = params
            @association_name = declaration.name.to_s
            @reflection = reflection
            @cloner_options = params
            @cloner_options.merge!(traits: declaration.traits) if declaration.traits
          end

          def call(_record)
            raise NotImplementedError
          end

          def association
            @_association ||= source.__send__(association_name)
          end

          def clone_one(child)
            cloner = cloner_for(child)
            cloner ? cloner.call(child, cloner_options) : clone_record(child)
          end

          def with_scope
            base_scope = association_dataset
            if scope.is_a?(Symbol)
              base_scope.__send__(scope)
            elsif scope.is_a?(Proc)
              base_scope.instance_exec(params, &scope) || base_scope
            else
              base_scope
            end.to_a
          end

          private

          def clone_record(record)
            Clowne.resolve_adapter(:sequel).copier.call(record)
          end

          def for_clonable(record)
            if clonable_assoc?(record)
              yield
            else
              warn <<-WARN
                Relation #{association_name} does not configure for Sequel::Plugins::NestedAttributes
              WARN
            end

            record
          end

          def clonable_assoc?(record)
            record.class.plugins.include?(::Sequel::Plugins::NestedAttributes) &&
              record.respond_to?(:"#{association_name}_attributes=")
          end

          # TODO: think how to get rid of many conversion
          def clonable_attributes(record, prev_assoc = nil)
            record.associations.each_with_object(record.dup.to_hash) do |(name, value), memo|
              next if !prev_assoc.nil? && value.is_a?(prev_assoc)

              association_hash =
                if value.is_a?(Array)
                  value.map { |v| clonable_attributes(v, record.class) }
                else
                  clonable_attributes(value, record.class)
                end
              memo["#{name}_attributes"] = association_hash
            end
          end

          def cloner_for(child)
            return clone_with if clone_with

            return child.class.cloner_class if child.class.respond_to?(:cloner_class)
          end

          def association_dataset
            @_association_dataset ||= source.__send__([association_name, 'dataset'].join('_'))
          end

          attr_reader :source, :scope, :clone_with, :params, :association_name,
                      :reflection, :cloner_options
        end
      end
    end
  end
end

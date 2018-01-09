# frozen_string_literal: true

require 'clowne/adapters/base/association'

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class Base < Base::Association
          private

          def clone_record(record)
            Clowne::Adapters::Sequel::Copier.call(record)
          end

          def init_scope
            @_init_scope ||= source.__send__([association_name, 'dataset'].join('_'))
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
            record.associations.each_with_object(record.to_hash) do |(name, value), memo|
              next if !prev_assoc.nil? && value.is_a?(prev_assoc)

              memo["#{name}_attributes"] = clone_association(record.class, value)
            end
          end

          def clone_association(record_class, assoc)
            if assoc.is_a?(Array)
              assoc.map { |v| clonable_attributes(v, record_class) }
            else
              clonable_attributes(assoc, record_class)
            end
          end
        end
      end
    end
  end
end

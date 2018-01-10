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

          def with_clonable(record)
            if clonable_assoc?
              yield
            else
              warn <<-WARN
                Relation #{association_name} does not configure for Sequel::Plugins::NestedAttributes
              WARN
            end

            record
          end

          def clonable_assoc?
            source.class.plugins.include?(::Sequel::Plugins::NestedAttributes) &&
              source.respond_to?(:"#{association_name}_attributes=")
          end
        end
      end
    end
  end
end

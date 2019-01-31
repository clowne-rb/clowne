# frozen_string_literal: true

require 'clowne/adapters/sequel/specifications/after_persist_does_not_support'

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Resolvers
        class AfterPersist
          def self.call(_source, record, _declaration, **)
            operation = Clowne::Adapters::Sequel::Operation.current
            operation.add_after_persist(
              proc do
                raise Specifications::AfterPersistDoesNotSupportException
              end
            )
            record
          end
        end
      end
    end
  end
end

Clowne::Adapters::Sequel.register_resolver(
  :after_persist,
  Clowne::Adapters::Sequel::Resolvers::AfterPersist
)

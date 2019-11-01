# frozen_string_literal: true

require "clowne/adapters/sequel/specifications/after_persist_does_not_support"

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Resolvers
        class AfterPersist
          def self.call(_source, _record, _declaration, **)
            raise Specifications::AfterPersistDoesNotSupportException
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

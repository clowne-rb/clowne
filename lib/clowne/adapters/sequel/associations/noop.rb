# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class Noop < Base
          def call(record)
            warn("[Clowne] Reflection #{reflection.class.name} is not supported")
            record
          end
        end
      end
    end
  end
end

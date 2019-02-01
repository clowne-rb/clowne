# frozen_string_literal: true

module Clowne
  module Adapters
    class Sequel
      module Specifications # :nodoc: all
        class AfterPersistDoesNotSupportException < StandardError
          def message
            'Sequel adapter does not support after_persist callback'
          end
        end
      end
    end
  end
end

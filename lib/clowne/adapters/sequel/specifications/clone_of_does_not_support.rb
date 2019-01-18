# frozen_string_literal: true

module Clowne
  module Adapters
    class Sequel
      module Specifications
        module CloneOfDoesNotSupport
          class CloneOfDoesNotSupportException < StandardError
            def message
              'Sequel adapter does not support #clone_of method'
            end
          end

          def clone_of(_record)
            raise CloneOfDoesNotSupportException
          end
        end
      end
    end
  end
end

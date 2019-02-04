# frozen_string_literal: true

require 'clowne/adapters/base/association'

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecordSync
      module Associations
        class Base < Base::Association
          private

          def init_scope
            association
          end
        end
      end
    end
  end
end

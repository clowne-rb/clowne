# frozen_string_literal: true

require 'clowne/adapters/base/association'

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      module Associations
        class Base < Base::Association
          private

          def clone_record(record)
            Clowne.resolve_adapter(:active_record).copier.call(record)
          end

          def init_scope
            association
          end
        end
      end
    end
  end
end

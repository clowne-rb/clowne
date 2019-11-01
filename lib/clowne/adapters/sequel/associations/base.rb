# frozen_string_literal: true

require "clowne/adapters/base/association"

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class Base < Base::Association
          private

          def init_scope
            @_init_scope ||= source.__send__([association_name, "dataset"].join("_"))
          end

          def record_wrapper(record)
            operation.record_wrapper(record)
          end

          def operation
            @_operation ||= adapter.class.operation_class.current
          end
        end
      end
    end
  end
end

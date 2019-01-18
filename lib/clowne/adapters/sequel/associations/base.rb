# frozen_string_literal: true

require 'forwardable'
require 'clowne/adapters/base/association'

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class Base < Base::Association
          extend Forwardable

          private

          def_delegators :operation, :record_wrapper
          def_delegators Clowne::Adapters::Sequel, :dup_record

          def init_scope
            @_init_scope ||= source.__send__([association_name, 'dataset'].join('_'))
          end

          def operation
            @_operation ||= Clowne::Adapters::Sequel.operation_class.current
          end
        end
      end
    end
  end
end

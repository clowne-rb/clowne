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

          def clone_record(record)
            Clowne::Adapters::Sequel::Copier.call(record)
          end

          def init_scope
            @_init_scope ||= source.__send__([association_name, 'dataset'].join('_'))
          end

          def operation
            @_operation ||= Clowne::Utils::Operation.current
          end
        end
      end
    end
  end
end

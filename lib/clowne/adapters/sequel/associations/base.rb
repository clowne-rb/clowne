# frozen_string_literal: true

require 'clowne/adapters/base/association'

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class Base < Base::Association
          private

          def clone_record(record)
            Clowne::Adapters::Sequel::Copier.call(record)
          end

          def init_scope
            @_init_scope ||= source.__send__([association_name, 'dataset'].join('_'))
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'forwardable'
require 'clowne/adapters/base/association'

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      module Associations
        class Base < Base::Association
          extend Forwardable

          private

          def_delegators Clowne::Adapters::ActiveRecord, :dup_record

          def init_scope
            association
          end
        end
      end
    end
  end
end

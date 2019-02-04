# frozen_string_literal: true

module Clowne
  module Adapters
    # Cloning adapter for ActiveRecordSync
    class ActiveRecordSync < Base
      class << self
        def dup_record(record)
          operation = operation_class.current
          operation.mapper.clone_of(record)
        end
      end
    end
  end
end

require 'clowne/adapters/active_record_sync/associations'
require 'clowne/adapters/active_record_sync/resolvers/association'

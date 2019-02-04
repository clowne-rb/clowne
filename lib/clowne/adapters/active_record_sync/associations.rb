# frozen_string_literal: true

require 'clowne/adapters/active_record_sync/associations/base'
# require 'clowne/adapters/active_record_sync/associations/noop'
require 'clowne/adapters/active_record_sync/associations/has_one'
# require 'clowne/adapters/active_record_sync/associations/has_many'
# require 'clowne/adapters/active_record_sync/associations/has_and_belongs_to_many'

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecordSync
      module Associations
        extend ActiveRecord::Associations

        AR_2_CLONER = {
          has_one: HasOne,
          # has_many: HasMany,
          # has_and_belongs_to_many: HABTM
        }.freeze

        def cloner_for(reflection)
          super
        end

        module_function :cloner_for
      end
    end
  end
end

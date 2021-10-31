# frozen_string_literal: true

require "clowne/adapters/active_record/associations/base"
require "clowne/adapters/active_record/associations/noop"
require "clowne/adapters/active_record/associations/belongs_to"
require "clowne/adapters/active_record/associations/has_one"
require "clowne/adapters/active_record/associations/has_many"
require "clowne/adapters/active_record/associations/has_and_belongs_to_many"

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      module Associations
        AR_2_CLONER = {
          belongs_to: BelongsTo,
          has_one: HasOne,
          has_many: HasMany,
          has_and_belongs_to_many: HABTM
        }.freeze

        # Returns an association cloner class for reflection
        def self.cloner_for(reflection)
          if reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)
            Noop
          else
            AR_2_CLONER.fetch(reflection.macro, Noop)
          end
        end
      end
    end
  end
end

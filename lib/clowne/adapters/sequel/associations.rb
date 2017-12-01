# frozen_string_literal: true

require 'clowne/adapters/sequel/associations/base'
require 'clowne/adapters/sequel/associations/noop'
require 'clowne/adapters/sequel/associations/one_to_one'
require 'clowne/adapters/sequel/associations/one_to_many'
# require 'clowne/adapters/active_record/associations/has_and_belongs_to_many'

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        Sequel_2_CLONER = {
          one_to_one: OneToOne,
          one_to_many: OneToMany,
          # has_and_belongs_to_many: HABTM
        }.freeze

        # Returns an association cloner class for reflection
        def self.cloner_for(reflection)
          # if reflection.is_a?(::Sequel::Reflection::ThroughReflection)
          #   Noop
          # else
          Sequel_2_CLONER.fetch(reflection[:type], Noop)
          # end
        end
      end
    end
  end
end

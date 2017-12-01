# frozen_string_literal: true

require 'clowne/adapters/sequel/associations/base'
require 'clowne/adapters/sequel/associations/noop'
require 'clowne/adapters/sequel/associations/one_to_one'
require 'clowne/adapters/sequel/associations/one_to_many'
require 'clowne/adapters/sequel/associations/many_to_many'

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        Sequel_2_CLONER = {
          one_to_one: OneToOne,
          one_to_many: OneToMany,
          many_to_many: ManyToMany
        }.freeze

        # Returns an association cloner class for reflection
        def self.cloner_for(reflection)
          Sequel_2_CLONER.fetch(reflection[:type], Noop)
        end
      end
    end
  end
end

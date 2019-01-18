# frozen_string_literal: true

require 'clowne/ext/orm_ext'

module Clowne
  module Adapters
    # Cloning adapter for Sequel
    class Sequel < Base
      class << self
        def dup_record(record)
          Clowne::Adapters::Sequel::Copier.call(record)
        end

        def operation_class
          Clowne::Adapters::Sequel::Operation
        end
      end
    end
  end
end

::Sequel::Model.extend Clowne::Ext::ORMExt

require 'clowne/adapters/sequel/operation'
require 'clowne/adapters/sequel/associations'
require 'clowne/adapters/sequel/copier'
require 'clowne/adapters/sequel/record_wrapper'
require 'clowne/adapters/sequel/resolvers/association'

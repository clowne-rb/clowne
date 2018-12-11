# frozen_string_literal: true

require 'clowne/ext/orm_ext'

module Clowne
  module Adapters
    # Cloning adapter for Sequel
    class Sequel < Base
      def init_record(source)
        RecordWrapper.new(source)
      end

      def dup_source(source)
        Clowne::Adapters::Sequel::Copier.call(source)
      end
    end
  end
end

::Sequel::Model.extend Clowne::Ext::ORMExt

require 'clowne/adapters/sequel/associations'
require 'clowne/adapters/sequel/copier'
require 'clowne/adapters/sequel/record_wrapper'
require 'clowne/adapters/sequel/resolvers/association'

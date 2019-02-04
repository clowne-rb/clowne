# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecordSync
      module Resolvers
        class UnknownAssociation < StandardError; end

        class Association < ActiveRecord::Resolvers::Association; end
      end
    end
  end
end

Clowne::Adapters::ActiveRecordSync.register_resolver(
  :association,
  Clowne::Adapters::ActiveRecordSync::Resolvers::Association,
  before: :nullify
)

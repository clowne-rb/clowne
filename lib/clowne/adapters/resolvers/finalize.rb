# frozen_string_literal: true

module Clowne
  module Adapters
    class Resolvers
      module Finalize # :nodoc: all
        def self.call(source, record, declaration, params:, **_options)
          declaration.block.call(source, record, params)
          record
        end
      end
    end
  end
end

Clowne::Adapters::Base.register_resolver(
  :finalize, Clowne::Adapters::Resolvers::Finalize,
  after: :nullify
)

# frozen_string_literal: true

module Clowne
  module Adapters
    class Resolvers
      module InitAs # :nodoc: all
        # rubocop: disable Metrics/ParameterLists
        def self.call(source, _record, declaration, params:, adapter:, **_options)
          adapter.init_record(declaration.block.call(source, **params))
        end
        # rubocop: enable Metrics/ParameterLists
      end
    end
  end
end

Clowne::Adapters::Base.register_resolver(
  :init_as,
  Clowne::Adapters::Resolvers::InitAs,
  prepend: true
)

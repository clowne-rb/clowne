# frozen_string_literal: true

module Clowne
  class Resolvers
    module InitAs # :nodoc: all
      def self.call(source, _record, declaration, params:, adapter:, **_options)
        adapter.init_record(declaration.block.call(source, **params))
      end
      # rubocop: enable Metrics/ParameterLists
    end
  end
end

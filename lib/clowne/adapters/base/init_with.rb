# frozen_string_literal: true

module Clowne
  module Adapters
    class Base
      module InitWith # :nodoc: all
        # rubocop: disable Metrics/ParameterLists
        def self.call(source, _record, declaration, params:, adapter:, **_options)
          adapter.init_record(declaration.block.call(source, params))
        end
      end
    end
  end
end

Clowne::Adapters::Base.register_resolver(
  :init_with,
  Clowne::Adapters::Base::InitWith,
  prepend: true
)

# frozen_string_literal: true

module Clowne
  module Adapters
    class Resolvers
      module PostProcessing # :nodoc: all
        def self.call(source, record, declaration, params:, **_options)
          operation = Clowne::Operation.current
          params ||= {}
          operation.add_post_processing(
            proc do
              declaration.block.call(source, record, params.merge(mapper: operation.mapper))
            end
          )
          record
        end
      end
    end
  end
end

Clowne::Adapters::Base.register_resolver(
  :post_processing, Clowne::Adapters::Resolvers::PostProcessing,
  after: :finalize
)

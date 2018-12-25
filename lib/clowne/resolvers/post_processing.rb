# frozen_string_literal: true

module Clowne
  class Resolvers
    module PostProcessing # :nodoc: all
      def self.call(source, record, declaration, params:, **_options)
        operation = Clowne::Utils::Operation.current
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

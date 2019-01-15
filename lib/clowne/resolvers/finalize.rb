# frozen_string_literal: true

module Clowne
  class Resolvers
    module Finalize # :nodoc: all
      def self.call(source, record, declaration, params:, **_options)
        declaration.block.call(source, record, params)
        record
      end
    end
  end
end

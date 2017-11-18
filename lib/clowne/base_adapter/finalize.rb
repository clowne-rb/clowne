# frozen_string_literal: true

module Clowne
  module BaseAdapter
    class Finalize # :nodoc: all
      def self.call(source, record, declaration, params)
        if declaration.block.is_a?(Proc)
          declaration.block.call(source, record, params)
        end
        record
      end
    end
  end
end

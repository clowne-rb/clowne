# frozen_string_literal: true

module Clowne
  module BaseAdapter
    class Finalize
      def self.call(source, record, declaration, params)
        if ! declaration.block.is_a?(Proc)
          record
        else
          declaration.block.call(source, record, params)
          record
        end
      end
    end
  end
end

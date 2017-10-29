module Clowne
  module BaseAdapter
    class Finalize
      def self.call(source, record, declaration)
        if ! declaration.block.is_a?(Proc)
          record
        else
          declaration.block.call(source, record)
          record
        end
      end
    end
  end
end

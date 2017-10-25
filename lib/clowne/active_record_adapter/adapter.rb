module Clowne
  module ActiveRecordAdapter
    class Adapter < Clowne::IAdapter
      def close_association(record, association)
        CloneAssociation.call(record, association)
      end
    end
  end
end

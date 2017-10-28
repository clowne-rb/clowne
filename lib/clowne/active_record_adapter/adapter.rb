module Clowne
  module ActiveRecordAdapter
    class Adapter < Clowne::BaseAdapter::Adapter
      def reflections_for(record)
        record.class.reflections
      end

      def close_association(record, association)
        CloneAssociation.call(record, association)
      end
    end
  end
end

module Clowne
  module BaseAdapter
    class Adapter
      # Return hash of reflections
      # Example: {"topic"=> #<ActiveRecord::Reflection::BelongsToReflection:0x007fb37a5cbd38 }
      def reflections_for(record)
        raise 'Need implementation'
      end

      # Return record with cloned association
      def close_association(record, association)
        raise 'Need implementation'
      end
    end
  end
end

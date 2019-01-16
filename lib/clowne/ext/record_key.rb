# frozen_string_literal: true

module Clowne
  module Ext
    module RecordKey # :nodoc: all
      def key(record)
        id = record.respond_to?(:id) ? record.id : record.__id__
        [record.class.name, id].join('#')
      end
    end
  end
end

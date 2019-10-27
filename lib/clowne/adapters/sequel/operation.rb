# frozen_string_literal: true

require 'clowne/ext/record_key'

module Clowne
  module Adapters
    class Sequel # :nodoc: all
      class Operation < Clowne::Utils::Operation
        include Clowne::Ext::RecordKey
        def initialize(mapper)
          super
          @records = {}
        end

        def record_wrapper(record)
          @records[key(record)] ||= RecordWrapper.new(record)
        end

        def hash
          @records[key(@clone)]
        end

        def to_record
          return @_record if defined?(@_record)

          record_wrapper(@clone)

          @_record = @records[key(@clone)].to_model.tap do
            run_after_clone
          end
        end
      end
    end
  end
end

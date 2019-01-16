# frozen_string_literal: true

require 'clowne/ext/record_key'

module Clowne
  module Adapters
    class Sequel
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
          @_record if defined?(@_record)

          @_record = @records[key(@clone)].to_model
        end
      end
    end
  end
end

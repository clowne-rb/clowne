# frozen_string_literal: true

require 'clowne/ext/record_key'
require 'clowne/adapters/sequel/specifications/clone_of_does_not_support'

module Clowne
  module Adapters
    class Sequel # :nodoc: all
      class Operation < Clowne::Utils::Operation
        include Clowne::Ext::RecordKey

        def initialize(mapper)
          super
          decorate_mapper
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

          @_record = @records[key(@clone)].to_model
        end

        private

        def decorate_mapper
          return unless mapper.class == Clowne::Utils::CloneMapper

          mapper.extend(Specifications::CloneOfDoesNotSupport)
        end
      end
    end
  end
end

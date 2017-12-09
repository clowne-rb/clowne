module Clowne
  module Adapters # :nodoc: all
    class Sequel
      class RecordWrapper
        attr_reader :record

        def initialize(record)
          @record = record
          @association_store = {}
        end

        def remember_assoc(association, value)
          @association_store[association] = value
        end

        def save
          to_model.save
        end

        def to_model
          @record.class.new(build_record)
        end

        def build_record
          @association_store.each_with_object(record.to_hash) do |(name, value), memo|
            memo[name] = association_to_model(value)
          end
        end

        def method_missing(method, *args, &block)
          record.send(method, *args, &block)
        end

        private

        def association_to_model(assoc)
          if assoc.is_a?(Array)
            assoc.map(&:build_record)
          else
            assoc.build_record
          end
        end
      end
    end
  end
end

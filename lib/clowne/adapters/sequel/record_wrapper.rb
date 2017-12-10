module Clowne
  module Adapters # :nodoc: all
    class Sequel
      class RecordWrapper
        attr_reader :record, :association_store

        class << self
          def to_hash(record_wrapper)
            if record_wrapper.is_a?(RecordWrapper)
              init_hash = record_wrapper.record.to_hash
              record_wrapper.association_store.each_with_object(init_hash) do |(name, value), memo|
                memo[name] = association_to_model(value)
              end
            else
              record_wrapper.to_hash
            end
          end

          def association_to_model(assoc)
            if assoc.is_a?(Array)
              assoc.map { |a| RecordWrapper.to_hash(a) }
            elsif assoc.is_a?(RecordWrapper)
              RecordWrapper.to_hash(assoc)
            else
              assoc.to_hash
            end
          end
        end

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
          @record.class.new(RecordWrapper.to_hash(self))
        end

        # def build_record
        #   @association_store.each_with_object(record.to_hash) do |(name, value), memo|
        #     memo[name] = association_to_model(value)
        #   end
        # end

        def method_missing(method, *args, &block)
          record.send(method, *args, &block)
        end

        private

        # def association_to_model(assoc)
        #   if assoc.is_a?(Array)
        #     assoc.map(&:build_record)
        #   elsif assoc.is_a?(RecordWrapper)
        #     assoc.build_record
        #   else
        #     assoc.to_hash
        #   end
        # end
      end
    end
  end
end

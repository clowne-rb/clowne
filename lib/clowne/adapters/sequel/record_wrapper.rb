# frozen_string_literal: true

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

          private

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

        def respond_to_missing?(method_name, include_private = false)
          record.respond_to?(method_name) || super
        end

        def method_missing(method_name, *args, &block)
          if record.respond_to?(method_name)
            record.public_send(method_name, *args, &block)
          else
            super
          end
        end
      end
    end
  end
end

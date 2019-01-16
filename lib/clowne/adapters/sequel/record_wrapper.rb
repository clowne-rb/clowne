# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      class RecordWrapper
        attr_reader :record, :association_store

        def initialize(record)
          @record = record
          @association_store = {}
        end

        def remember_assoc(association, value)
          @association_store[association] = value
        end

        # def save
        #   to_model.save
        # end

        def to_model
          # association_store.each_with_object(record) do |(name, value), acc|
          #   acc.send("#{name}=", association_to_model(value))
          # end
          record.class.new(to_hash)
        end

        def to_hash
          init_hash = record.to_hash
          association_store.each_with_object(init_hash) do |(name, value), acc|
            acc[name] = association_to_model(value)
          end
        end

        # def respond_to_missing?(method_name, include_private = false)
        #   record.respond_to?(method_name) || super
        # end

        # def method_missing(method_name, *args, &block)
        #   if record.respond_to?(method_name)
        #     record.public_send(method_name, *args, &block)
        #   else
        #     super
        #   end
        # end

        private

        def association_to_model(assoc)
          if assoc.is_a?(Array)
            assoc.map(&:to_hash)
          else
            assoc.to_hash
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      class Copier
        class << self
          def call(source)
            nullify_fields = [:id] + [:create_timestamp_field, :update_timestamp_field].map do |timestamp|
              source.class.instance_variable_get("@#{ timestamp }")
            end

            hash = source.dup.to_hash.tap do |hash|
              nullify_fields.each { |field| hash.delete(field) }
            end

            source.class.new(hash)
          end
        end
      end
    end
  end
end

Clowne::Adapters::Sequel.register_copier(
  Clowne::Adapters::Sequel::Copier
)

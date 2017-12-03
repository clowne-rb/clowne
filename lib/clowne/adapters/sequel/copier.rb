# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      class Copier
        class << self
          def call(source)
            nullify_attrs = [:create_timestamp_field, :update_timestamp_field].map do |timestamp|
              source.class.instance_variable_get("@#{timestamp}")
            end + [:id]

            dup_hash = source.dup.to_hash.tap do |hash|
              nullify_attrs.each { |field| hash.delete(field) }
            end

            source.class.new(dup_hash)
          end
        end
      end
    end
  end
end

Clowne::Adapters::Sequel.register_copier(
  Clowne::Adapters::Sequel::Copier
)

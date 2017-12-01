# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      class Copier
        class << self
          def call(source)
            source.dup.tap do |source|
              [:create_timestamp_field, :update_timestamp_field].each do |timestamp|
                field = source.class.instance_variable_get("@#{ timestamp }")
                source.__send__("#{field}=", nil) if field
              end
            end
          end
        end
      end
    end
  end
end

Clowne::Adapters::Sequel.register_copier(
  Clowne::Adapters::Sequel::Copier
)

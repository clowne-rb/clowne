# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      class Copier
        class << self
          def call(source)
            source.dup
          end
        end
      end
    end
  end
end

Clowne::Adapters::ActiveRecord.register_copier(
  Clowne::Adapters::ActiveRecord::Copier
)

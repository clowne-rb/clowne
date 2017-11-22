# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      class Association
        class << self
          def call(source, record, declaration, params:)
            reflection = source.class.reflections[declaration.name.to_s]

            cloner_class = Associations.cloner_for(reflection)

            cloner_class.new(reflection, source, declaration, params).call(record)

            record
          end
        end
      end
    end
  end
end

Clowne::Adapters::ActiveRecord.register_resolver(:association, Clowne::Adapters::ActiveRecord::Association)

# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      class Association
        class << self
          def call(source, record, declaration, params:, traits:)
            reflection = source.class.reflections[name]

            cloner_class = Associations::AR_2_CLONER.fetch(reflection.macro, Associations::Noop)

            cloner_class.new(reflection, source, declaration, params, traits).call(record)
          end
        end
      end
    end
  end
end

Clowne::Adapters::ActiveRecord.register_resolver(:association, Clowne::Adapters::ActiveRecord::Association)

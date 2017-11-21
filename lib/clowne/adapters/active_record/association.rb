# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      class Association
        class << self
          def call(source, record, declaration, params:, traits:)
            reflection = source.class.reflections[declaration.name.to_s]

            cloner_class =
              if reflection.is_a?(::ActiveRecord::Reflection::ThroughReflection)
                Associations::Noop
              else
                Associations::AR_2_CLONER.fetch(reflection.macro, Associations::Noop)
              end

            cloner_class.new(reflection, source, declaration, params, traits).call(record)
          end
        end
      end
    end
  end
end

Clowne::Adapters::ActiveRecord.register_resolver(:association, Clowne::Adapters::ActiveRecord::Association)

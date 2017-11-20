# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      class AllAssociations
        class << self
          def call(source, record, declaration, **_options)
            source.class.reflections.each do |name, reflection|
              next if declaration.excludes.include?(name)

              cloner_class = Associations::AR_2_CLONER.fetch(reflection.macro, Associations::Noop)

              cloner_class.new(reflection, source, declaration, params, traits).call(record)
            end
          end
        end
      end
    end
  end
end

Clowne::Adapters::ActiveRecord.register_resolver(
  :all_associations, Clowne::Adapters::ActiveRecord::AllAssociations
)

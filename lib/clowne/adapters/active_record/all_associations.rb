# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      class AllAssociations
        class << self
          def call(source, record, declaration, params:)
            source.class.reflections.each do |name, reflection|
              next if declaration.excludes.include?(name)

              next if reflection.macro == :belongs_to

              cloner_class = Associations.cloner_for(reflection)

              cloner_class.new(reflection, source, declaration, params).call(record)
            end

            record
          end
        end
      end
    end
  end
end

Clowne::Adapters::ActiveRecord.register_resolver(
  :all_associations, Clowne::Adapters::ActiveRecord::AllAssociations
)

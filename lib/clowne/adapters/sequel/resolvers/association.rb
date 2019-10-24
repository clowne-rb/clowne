# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Resolvers
        class Association
          class << self
            # rubocop: disable Metrics/ParameterLists
            def call(source, record, declaration, adapter:, params:, **_options)
              with_clonable(source, record, declaration) do
                reflection = source.class.association_reflections[declaration.name.to_sym]

                cloner_class = Associations.cloner_for(reflection)

                cloner_class.new(reflection, source, declaration, adapter, params).call(record)

                record
              end
            end
            # rubocop: enable Metrics/ParameterLists

            private

            def with_clonable(source, record, declaration)
              if clonable_assoc?(source, declaration)
                yield(record)
              else
                warn <<-WARN
                  Relation #{declaration.name} of #{source.class.name} does not configure for Sequel::Plugins::NestedAttributes
                WARN
              end

              record
            end

            def clonable_assoc?(source, declaration)
              source.class.plugins.include?(::Sequel::Plugins::NestedAttributes) &&
                source.respond_to?(:"#{declaration.name}_attributes=")
            end
          end
        end
      end
    end
  end
end

Clowne::Adapters::Sequel.register_resolver(
  :association,
  Clowne::Adapters::Sequel::Resolvers::Association
)

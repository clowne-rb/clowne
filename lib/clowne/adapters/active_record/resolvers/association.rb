# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      module Resolvers
        class UnknownAssociation < StandardError; end

        class Association
          class << self
            # rubocop: disable Metrics/ParameterLists
            def call(source, record, declaration, adapter:, params:, **_options)
              reflection = source.class.reflections[declaration.name.to_s]

              if reflection.nil?
                raise UnknownAssociation,
                  "Association #{declaration.name} couldn't be found for #{source.class}"
              end

              cloner_class = Associations.cloner_for(reflection)

              cloner_class.new(reflection, source, declaration, adapter, params).call(record)

              record
            end
            # rubocop: enable Metrics/ParameterLists
          end
        end
      end
    end
  end
end

Clowne::Adapters::ActiveRecord.register_resolver(
  :association,
  Clowne::Adapters::ActiveRecord::Resolvers::Association,
  before: :nullify
)

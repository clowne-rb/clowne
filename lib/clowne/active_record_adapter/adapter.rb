# frozen_string_literal: true

module Clowne
  module ActiveRecordAdapter
    class Adapter < Clowne::BaseAdapter::Adapter # :nodoc: all
      RESOLVERS = {
        Clowne::Declarations::IncludeAssociation => Clowne::ActiveRecordAdapter::Association,
        Clowne::Declarations::Nullify => Clowne::BaseAdapter::Nullify,
        Clowne::Declarations::Finalize => Clowne::BaseAdapter::Finalize
      }.freeze

      class << self
        def reflections_for(source)
          source.class.reflections
        end

        def cloner_for(relation_name)
          name = ActiveSupport::Inflector.singularize(relation_name)
          expected_cloner = [name.capitalize, 'Cloner'].join
          cloner = ActiveSupport::Inflector.safe_constantize(expected_cloner)
          cloner if cloner && Clowne::Cloner.descendants.include?(cloner)
        end

        def plain_clone(source)
          source.dup
        end

        private

        def resolver(declaration_class)
          RESOLVERS.fetch(declaration_class)
        end
      end
    end
  end
end

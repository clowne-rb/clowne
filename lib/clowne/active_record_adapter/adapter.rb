module Clowne
  module ActiveRecordAdapter
    class Adapter < Clowne::BaseAdapter::Adapter
      RESOLVERS = {
        Clowne::Declarations::IncludeAssociation => Clowne::ActiveRecordAdapter::Association,
        Clowne::Declarations::Nullify => Clowne::BaseAdapter::Nullify,
        Clowne::Declarations::Finalize => Clowne::BaseAdapter::Finalize,
      }.freeze

      class << self
        def reflections_for(source)
          source.class.reflections
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

module Clowne
  module ActiveRecordAdapter
    class Adapter < Clowne::BaseAdapter::Adapter
      class << self
        def reflections_for(source)
          source.class.reflections
        end

        def plain_dup(source)
          source.dup
        end

        private

        def resolver(declaration_class)
          {
            Clowne::Declarations::IncludeAssociation => Clowne::ActiveRecordAdapter::CloneAssociation,
            Clowne::Declarations::Nullify => Clowne::BaseAdapter::Nullify,
            Clowne::Declarations::Finalize => Clowne::BaseAdapter::Finalize,
          }
        end
      end
    end
  end
end

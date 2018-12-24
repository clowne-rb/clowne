# frozen_string_literal: true

require 'clowne/adapters/registry'

require 'clowne/resolvers/init_as'
require 'clowne/resolvers/nullify'
require 'clowne/resolvers/finalize'
require 'clowne/resolvers/post_processing'

module Clowne
  module Adapters
    # ORM-independant adapter (just calls #dup).
    # Works with nullify/finalize.
    class Base
      include Clowne::Adapters::Registry::Container

      # Using a plan make full duplicate of record
      # +source+:: Instance of cloned object (ex: User.new(posts: posts))
      # +plan+:: Array of Declarations
      # +params+:: Custom params hash
      def clone(source, plan, params: {})
        declarations = plan.declarations
        declarations.inject(init_record(dup_source(source))) do |record, (type, declaration)|
          resolver_for(type).call(source, record, declaration, params: params, adapter: self)
        end
      end

      def dup_source(source)
        source.dup
      end

      def init_record(record)
        # Override in custom adapters
        record
      end
    end
  end
end

Clowne::Adapters::Base.register_resolver(
  :init_as,
  Clowne::Resolvers::InitAs,
  prepend: true
)

Clowne::Adapters::Base.register_resolver(
  :nullify,
  Clowne::Resolvers::Nullify
)

Clowne::Adapters::Base.register_resolver(
  :finalize, Clowne::Resolvers::Finalize,
  after: :nullify
)

Clowne::Adapters::Base.register_resolver(
  :post_processing, Clowne::Resolvers::PostProcessing,
  after: :finalize
)

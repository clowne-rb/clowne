# frozen_string_literal: true

require 'clowne/adapters/registry'

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
        source.dup.tap do |clone|
          operation = Clowne::Operation.current
          operation.add_mapping(source, clone)
        end
      end

      def init_record(record)
        # Override in custom adapters
        record
      end
    end
  end
end

require 'clowne/adapters/resolvers/init_as'
require 'clowne/adapters/resolvers/nullify'
require 'clowne/adapters/resolvers/finalize'
require 'clowne/adapters/resolvers/post_processing'

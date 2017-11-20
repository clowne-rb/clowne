# frozen_string_literal: true

module Clowne
  module Adapters
    # ORM-independant adapter (just calls #dup).
    # Works with nullify/finalize.
    class Base
      class << self
        def inherited(subclass)
          # Register all resolvers
          resolvers.each do |k, v|
            subclass.register_resolver(k, v)
          end
        end

        def resolver_for(type)
          resolvers[type] || raise("Uknown resolver #{type} for #{self}")
        end

        def register_resolver(type, resolver)
          resolvers[type] = resolver
        end

        protected

        def resolvers
          @resolvers ||= {}
        end
      end

      # Using a plan make full duplicate of record
      # +source+:: Instance of cloned object (ex: User.new(posts: posts))
      # +plan+:: Array of Declarations
      # +traits+:: List of active traits
      # +params+:: Custom params hash
      def clone(source, plan, traits: [], params: {})
        declarations = plan.declarations
        declarations.inject(clone_record(source)) do |record, (type, declaration)|
          resolver_for(type).call(source, record, declaration, traits: traits, params: params)
        end
      end

      def resolver_for(type)
        self.class.resolver_for(type)
      end

      # Return #dup if any
      def clone_record(source)
        source.dup
      end
    end
  end
end

require 'clowne/adapters/base/nullify'
require 'clowne/adapters/base/finalize'

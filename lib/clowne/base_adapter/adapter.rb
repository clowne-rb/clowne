# frozen_string_literal: true

module Clowne
  module BaseAdapter
    class Adapter # :nodoc: all
      class << self
        # Using a plan make full duplicate of record
        # +source+:: Instance of cloned object (ex: User.new(posts: posts))
        # +plan+:: Array of Declarations
        # +params+:: Instance of Clowne::Params (ex: Clowne::Parms.new({foo: :bar}))
        def clone(source, plan, params)
          declarations = plan.declarations
          declarations.inject(plain_clone(source)) do |record, declaration|
            resolver(declaration.class).call(source, record, declaration, params)
          end
        end

        # Return hash of reflections
        # Example: {"topic"=> #<ActiveRecord::Reflection::BelongsToReflection:0x007fb37a5cbd38 }
        def reflections_for(_source)
          raise NotImplementedError
        end

        def cloner_for(_relation_name)
          nil
        end

        # Return plain duplicate of source
        def plain_clone(_source)
          raise NotImplementedError
        end

        private

        def resolver(_declaration_class)
          raise NotImplementedError
        end
      end
    end
  end
end

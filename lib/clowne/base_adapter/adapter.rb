module Clowne
  module BaseAdapter
    class Adapter
      class << self
        # Using a plan make full duplicate of record
        def dup(plan, source)
          plan.inject(plain_dup(source)) do |record, declaration|
            resolver(declaration.class).call(source, record, declaration)
          end
        end

        # Return hash of reflections
        # Example: {"topic"=> #<ActiveRecord::Reflection::BelongsToReflection:0x007fb37a5cbd38 }
        def reflections_for(source)
          raise NotImplementedError
        end

        # Return plain duplicate of source
        def plain_dup(source)
          raise NotImplementedError
        end

        private

        def resolver(declaration_class)
          raise NotImplementedError
        end
      end
    end
  end
end

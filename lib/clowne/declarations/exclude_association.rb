module Clowne
  module Declarations
    class ExcludeAssociation < Struct.new(:name)
      def compile(plan, _options)
        plan.delete(name)
        plan || {}
      end
    end
  end
end

module Clowne
  module Declarations
    class IncludeAssociation < Struct.new(:name, :scope, :options)
      def compile(plan, _options)
        plan[name] = self
        plan
      end
    end
  end
end

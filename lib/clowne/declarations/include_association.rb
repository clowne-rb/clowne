module Clowne
  module Declarations
    class IncludeAssociation < Struct.new(:name, :scope, :options)
      def compile(plan, _settings)
        plan[name] = self
        plan
      end
    end
  end
end

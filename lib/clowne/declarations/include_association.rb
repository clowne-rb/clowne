module Clowne
  module Declarations
    class IncludeAssociation < Struct.new(:name, :scope, :options)
      def compile(plan, _settings)
        plan[name] = self
        plan
      end

      def custom_cloner
        options && options[:clone_with]
      end
    end
  end
end

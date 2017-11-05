module Clowne
  module Declarations
    class IncludeAssociation < Struct.new(:name, :scope, :options)
      def compile(plan, _settings)
        plan.add(name, self)
      end

      def custom_cloner
        options && options[:clone_with]
      end
    end
  end
end

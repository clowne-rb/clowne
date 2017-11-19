# frozen_string_literal: true

module Clowne
  module Declarations
    IncludeAssociation = Struct.new(:name, :scope, :options)

    class IncludeAssociation # :nodoc: all
      def compile(plan, settings)
        if custom_cloner
          plan.add(name, self)
        else
          adapter = settings[:adapter]
          base_cloner = adapter.cloner_for(name)
          plan.add(name, self.class.new(name, scope, options_with_cloner(base_cloner)))
        end
      end

      def custom_cloner
        options && options[:clone_with]
      end

      private

      def options_with_cloner(cloner)
        if cloner
          options.merge(clone_with: cloner)
        else
          options
        end
      end
    end
  end
end

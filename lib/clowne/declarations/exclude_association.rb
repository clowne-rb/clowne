# frozen_string_literal: true

module Clowne
  module Declarations
    ExcludeAssociation = Struct.new(:name)

    class ExcludeAssociation # :nodoc: all
      def compile(plan, _settings)
        plan.delete(name)
      end
    end
  end
end

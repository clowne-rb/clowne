# frozen_string_literal: true

module Clowne
  module Declarations
    class ExcludeAssociation < Struct.new(:name)
      def compile(plan, _settings)
        plan.delete(name)
      end
    end
  end
end

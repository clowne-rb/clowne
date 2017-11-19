# frozen_string_literal: true

module Clowne
  module Declarations
    class IncludeAll # :nodoc: all
      def compile(plan, settings)
        object = settings[:object]
        adapter = settings[:adapter]
        reflections = adapter.reflections_for(object)
        reflections.each_key do |name|
          plan.add(name, Clowne::Declarations::IncludeAssociation.new(name.to_sym))
        end

        plan
      end
    end
  end
end

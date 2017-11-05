module Clowne
  module Declarations
    class IncludeAll
      def compile(plan, settings)
        object, adapter = settings[:object], settings[:adapter]
        reflections = adapter.reflections_for(object)
        reflections.each do |name, _ref|
          plan.add(name, Clowne::Declarations::IncludeAssociation.new(name.to_sym))
        end

        plan
      end
    end
  end
end

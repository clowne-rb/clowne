module Clowne
  module Declarations
    class IncludeAll
      def compile(plan, options)
        object, adapter = options[:object], options[:adapter]
        reflections = adapter.reflections_for(object)
        reflections.each do |name, _ref|
          name = name.to_sym
          plan[name.to_sym] = Clowne::Declarations::IncludeAssociation.new(name)
        end
        plan
      end
    end
  end
end

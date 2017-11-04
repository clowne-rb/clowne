module Clowne
  class UnprocessableSourceError < StandardError; end
  class ConfigurationError < StandardError; end

  class Cloner
    extend Clowne::DSL

    class << self
      def inherited(subclass)
        subclass.adapter(adapter)
        subclass.config(Clowne::Configuration.new(config.declarations.dup))
      end

      def call(object, **options)
        raise(UnprocessableSourceError, 'Nil is not cloneable object') if object.nil?

        plan = Clowne::Planner.compile(self, object, Clowne::Plan.new, **options)
        plan.validate!
        adapter.clone(object, plan, options.except(Clowne::Declarations::Trait::MARKER)) # TODO: #except is AS!
      end
    end
  end
end

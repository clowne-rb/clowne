module Clowne
  class UnprocessableSourceError < StandardError; end
  class ConfigurationError < StandardError; end

  class Cloner
    extend Clowne::DSL

    class << self
      def inherited(subclass)
        subclass.adapter(adapter)
        subclass.config(Clowne::Configuration.new(config.declarations.dup))
        (@descendants ||= []) << subclass
      end

      def descendants
        @descendants || []
      end

      def call(object, **options)
        raise(UnprocessableSourceError, 'Nil is not cloneable object') if object.nil?

        plan = Clowne::Planner.compile(self, object, Clowne::Plan.new, **options)
        plan.validate!
        adapter.clone(object, plan, skip_traits(options))
      end

      private

      def skip_traits(options)
        options.delete(Clowne::Declarations::Trait::MARKER)
        options
      end
    end
  end
end

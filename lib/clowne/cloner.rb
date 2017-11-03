module Clowne
  class UnprocessableSourceError < StandardError; end
  class ConfigurationError < StandardError; end

  class Cloner
    extend Clowne::DSL

    class << self
      def call(object, **options)
        raise(ConfigurationError, 'Adapter is not defined') unless adapter
        raise(UnprocessableSourceError, 'Nil is not cloneable object') if object.nil?

        plan = Clowne::Planner.compile(self, object, Clowne::Plan.new, **options)
        plan.validate!
        adapter.clone(object, plan, Clowne::Params.new(options.except(:for)))
      end
    end
  end
end

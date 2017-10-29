module Clowne
  class Cloner
    extend Clowne::DSL

    class << self
      def adapter(adapter = nil)
        @adapter ||= adapter
      end

      def call(object, **options)
        plan = Clowne::Planner.compile(self, object, {}, **options)
        @adapter.clone(object, plan, Clowne::Params.new(options.except(:for)))
      end
    end
  end
end

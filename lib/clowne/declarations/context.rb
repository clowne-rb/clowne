module Clowne
  module Declarations
    class Context < Struct.new(:name, :block)
      def compile(plan, options)
        object, adapter = options[:object], options[:adapter]
        anonymous_cloner = Class.new(Clowne::Cloner)
        anonymous_cloner.adapter(options[:adapter])
        anonymous_cloner.instance_eval(&block)

        Clowne::Planner.compile(anonymous_cloner, object, plan)
      end
    end
  end
end

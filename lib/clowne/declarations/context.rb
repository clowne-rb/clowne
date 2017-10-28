module Clowne
  module Declarations
    class Context < Struct.new(:name, :block)
      def compile(plan, settings)
        options = settings[:options]
        active_contexts = options && options[:for]

        if active_contexts.nil? || active_contexts.include?(name)
          compile_context(plan, settings)
        else
          plan
        end
      end

      private

      def compile_context(plan, settings)
        object, adapter, options = settings[:object], settings[:adapter], settings[:options]
        anonymous_cloner = Class.new(Clowne::Cloner)
        anonymous_cloner.adapter(adapter)
        anonymous_cloner.instance_eval(&block)

        Clowne::Planner.compile(anonymous_cloner, object, plan, options)
      end
    end
  end
end

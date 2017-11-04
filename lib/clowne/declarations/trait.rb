# frozen_string_literal: true

module Clowne
  module Declarations
    class Trait < Struct.new(:name, :block)
      MARKER = :traits

      def compile(plan, settings)
        options = settings[:options]
        active_traits = Array(options && options[MARKER])

        if active_traits.include?(name)
          compile_trait(plan, settings)
        else
          plan
        end
      end

      private

      def compile_trait(plan, settings)
        object, adapter, options = settings[:object], settings[:adapter], settings[:options]
        anonymous_cloner = Class.new(Clowne::Cloner)
        anonymous_cloner.adapter(adapter)
        anonymous_cloner.instance_eval(&block)

        Clowne::Planner.compile(anonymous_cloner, object, plan, options)
      end
    end
  end
end

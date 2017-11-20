# frozen_string_literal: true

module Clowne
  module Declarations
    Finalize = Struct.new(:block)

    class Finalize # :nodoc: all
      def compile(plan, _settings)
        plan.add(:finalize, self)
      end
    end
  end
end

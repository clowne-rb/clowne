# frozen_string_literal: true

module Clowne
  module Declarations
    Nullify = Struct.new(:attribute)

    class Nullify # :nodoc: all
      def compile(plan, _settings)
        plan.add(:nullify, self)
      end
    end
  end
end

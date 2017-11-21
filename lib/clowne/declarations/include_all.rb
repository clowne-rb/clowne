# frozen_string_literal: true

require 'set'

module Clowne
  module Declarations
    class IncludeAll # :nodoc: all
      attr_reader :excludes

      def initialize
        @excludes = Set.new
      end

      def compile(plan)
        # Remove all configured associations
        plan.remove(:association)
        plan.set(:all_associations, self)
      end

      def except!(name)
        @excludes << name.to_s
      end
    end
  end
end

# frozen_string_literal: true

module Clowne
  module Declarations
    class Base # :nodoc: all
      # Used with partial_apply.
      # By default match everything
      def matches?(_)
        true
      end
    end
  end
end

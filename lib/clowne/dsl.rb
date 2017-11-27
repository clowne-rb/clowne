# frozen_string_literal: true

module Clowne
  module DSL # :nodoc: all
    def adapter(adapter = nil)
      if adapter.nil?
        return @_adapter if instance_variable_defined?(:@_adapter)
        @_adapter = Clowne.default_adapter
      else
        @_adapter = Clowne.resolve_adapter(adapter)
      end
    end
  end
end

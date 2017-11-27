# frozen_string_literal: true

module Clowne
  module Ext
    # Add simple constantize method to String
    module StringConstantize
      refine String do
        def constantize
          names = split('::')

          Object.const_get(self) if names.empty?

          # Remove the first blank element in case of '::ClassName' notation.
          names.shift if names.size > 1 && names.first.empty?

          names.inject(Object) do |constant, name|
            constant.const_get(name)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Clowne
  module Adapters
    class Base
      module Nullify # :nodoc: all
        def self.call(_source, record, declaration, **_options)
          attr = declaration.attribute

          record.__send__("#{attr}=", nil)

          record
        end
      end
    end
  end
end

Clowne::Adapters::Base.register_resolver(:nullify, Clowne::Adapters::Base::Nullify)

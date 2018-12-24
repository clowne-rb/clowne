# frozen_string_literal: true

module Clowne
  class Resolvers
    module Nullify # :nodoc: all
      def self.call(_source, record, declaration, **_options)
        declaration.attributes.each do |attr|
          record.__send__("#{attr}=", nil)
        end

        record
      end
    end
  end
end

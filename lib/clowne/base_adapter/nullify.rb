# frozen_string_literal: true

module Clowne
  module BaseAdapter
    class Nullify # :nodoc: all
      def self.call(_source, record, declaration, _params)
        declaration.attributes.each do |attr|
          record.__send__("#{attr}=", nil)
        end

        record
      end
    end
  end
end

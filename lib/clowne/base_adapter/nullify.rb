module Clowne
  module BaseAdapter
    class Nullify
      def self.call(_source, record, declaration, _params)
        declaration.attributes.each do |attr|
          record.__send__("#{attr}=", nil)
        end

        record
      end
    end
  end
end

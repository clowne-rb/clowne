module Clowne
  class Cloner
    extend Clowne::DSL

    class << self
      def adapter(adapter = nil)
        @adapter ||= adapter
      end

      def call(object, params = {})
        puts object
        puts config
      end
    end
  end
end

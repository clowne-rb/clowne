require 'pry'
module Clowne
  class Cloner
    extend Clowne::DSL

    class << self
      def adapter(adapter || nil)
        @adapter = adapter
      end

      def call(object)
        puts object
        puts config
      end

      def lint!
        # Check all version of cloner
      end
    end
  end
end

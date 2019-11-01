# frozen_string_literal: true

require "clowne/ext/string_constantize"

module Clowne
  module Ext
    # Adds #cloner_class method to ORM base model
    module ORMExt
      using Clowne::Ext::StringConstantize

      def cloner_class
        return @_clowne_cloner if instance_variable_defined?(:@_clowne_cloner)

        cloner = "#{name}Cloner".constantize
        return @_clowne_cloner = cloner if cloner && cloner <= Clowne::Cloner

        @_clowne_cloner = superclass.cloner_class if superclass.respond_to?(:cloner_class)
      end
    end
  end
end

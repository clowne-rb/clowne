# frozen_string_literal: true

module Clowne
  module Adapters
    # Cloning adapter for Sequel
    class Sequel < Base
      # Adds #cloner_class method to Sequel::Model
      module SequelExt
        def cloner_class
          return @_clowne_cloner if instance_variable_defined?(:@_clowne_cloner)

          cloner = "#{name}Cloner".safe_constantize
          return @_clowne_cloner = cloner if cloner && cloner <= Clowne::Cloner

          @_clowne_cloner = superclass.cloner_class if superclass.respond_to?(:cloner_class)
        end
      end
    end
  end
end

::Sequel::Model.extend Clowne::Adapters::Sequel::SequelExt

require 'clowne/adapters/sequel/associations'
require 'clowne/adapters/sequel/association'
require 'clowne/adapters/sequel/copier'

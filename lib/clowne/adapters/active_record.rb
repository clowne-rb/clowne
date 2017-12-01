# frozen_string_literal: true

module Clowne
  module Adapters
    # Cloning adapter for ActiveRecord
    class ActiveRecord < Base
      # Adds #cloner_class method to ActiveRecord::Base
      module ActiveRecordExt
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

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::Base.extend Clowne::Adapters::ActiveRecord::ActiveRecordExt
end

require 'clowne/adapters/active_record/associations'
require 'clowne/adapters/active_record/association'
require 'clowne/adapters/active_record/all_associations'
require 'clowne/adapters/active_record/copier'

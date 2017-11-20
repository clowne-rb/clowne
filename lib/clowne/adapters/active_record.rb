# frozen_string_literal: true

module Clowne
  module Adapters
    # Cloning adapter for ActiveRecord
    class ActiveRecord < Base
      # Adds #cloner_class method to ActiveRecord::Base
      module ActiveRecordExt
        def cloner_class
          cloner = "#{self.class.name}Cloner".safe_constantize
          cloner if cloner && cloner <= Clowne::Cloner
        end
      end
    end
  end
end

require 'clowne/adapters/active_record/associations'
require 'clowne/adapters/active_record/association'
require 'clowne/adapters/active_record/all_associations'

# frozen_string_literal: true

require 'clowne/ext/orm_ext'

module Clowne
  module Adapters
    # Cloning adapter for ActiveRecord
    class ActiveRecord < Base
    end
  end
end

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::Base.extend Clowne::Ext::ORMExt
end

require 'clowne/adapters/active_record/associations'
require 'clowne/adapters/active_record/association'

# frozen_string_literal: true

require 'clowne/ext/orm_ext'

module Clowne
  module Adapters
    # Cloning adapter for Sequel
    class Sequel < Base
      # Using a plan make full duplicate of record
      # +source+:: Instance of cloned object (ex: User.new(posts: posts))
      # +plan+:: Array of Declarations
      # +params+:: Custom params hash
      def clone(source, plan, params: {})
        declarations = plan.declarations
        init_record = RecordWrapper.new(copier.call(source))

        declarations.inject(init_record) do |record, (type, declaration)|
          resolver_for(type).call(source, record, declaration, params: params)
        end
      end
    end
  end
end

::Sequel::Model.extend Clowne::Ext::ORMExt

require 'clowne/adapters/sequel/associations'
require 'clowne/adapters/sequel/association'
require 'clowne/adapters/sequel/copier'
require 'clowne/adapters/sequel/record_wrapper'

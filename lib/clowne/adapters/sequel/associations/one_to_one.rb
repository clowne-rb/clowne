# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class OneToOne < Base
          def call(record)
            child = association
            return record unless child
            warn '[Clowne] Has one association does not support scopes' unless scope.nil?

            child_clone = clone_one(child)
            child_clone[:"#{reflection[:key]}"] = nil
            # record.__send__(:"#{association_name}=", child_clone)
            record.__send__(:"#{association_name}_attributes=", child_clone.to_hash.except(:id))

            record
          end
        end
      end
    end
  end
end

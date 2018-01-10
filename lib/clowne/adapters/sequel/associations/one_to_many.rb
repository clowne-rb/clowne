# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class OneToMany < Base
          def call(record)
            clones =
              with_scope.map do |child|
                clone_one(child).tap do |child_clone|
                  child_clone[:"#{reflection[:key]}"] = nil
                end
              end
            record.remember_assoc(:"#{association_name}_attributes", clones)

            record
          end
        end
      end
    end
  end
end

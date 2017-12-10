# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class OneToMany < Base
          def call(record)
            with_clonable(record) do
              clones =
                with_scope.map do |child|
                  clone_one(child).tap do |child_clone|
                    child_clone[:"#{reflection[:key]}"] = nil
                  end
                  # child_clone
                  # clonable_attributes(child_clone)
                end
              record.remember_assoc(:"#{association_name}_attributes", clones)
              # record.__send__(:"#{association_name}_attributes=", clones)
            end
          end
        end
      end
    end
  end
end

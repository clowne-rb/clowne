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
                  child_clone = clone_one(child)
                  child_clone[:"#{reflection[:key]}"] = nil

                  clonable_attributes(child_clone)
                end
              record.__send__(:"#{association_name}_attributes=", clones)
            end
          end
        end
      end
    end
  end
end

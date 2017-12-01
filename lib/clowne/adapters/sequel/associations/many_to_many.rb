# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class ManyToMany < Base
          def call(record)
            clones =
              with_scope.map do |child|
                child_clone = clone_one(child)
                clonable_attributes(child_clone)
              end

            record.__send__(:"#{association_name}_attributes=", clones)

            record
          end
        end
      end
    end
  end
end

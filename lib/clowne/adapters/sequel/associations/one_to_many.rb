# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class OneToMany < Base
          def call(record)
            clones =
              with_scope.lazy.map do |child|
                clone_one(child).tap do |child_clone|
                  child_clone[:"#{reflection[:key]}"] = nil
                end
              end.map(&method(:record_wrapper))

            record_wrapper(record).remember_assoc(:"#{association_name}_attributes", clones.to_a)

            record
          end
        end
      end
    end
  end
end

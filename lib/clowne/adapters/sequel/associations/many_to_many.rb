# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class ManyToMany < Base
          def call(record)
            clones = with_scope.map { |child| clone_one(child) }

            record.remember_assoc(:"#{association_name}_attributes", clones)

            record
          end
        end
      end
    end
  end
end

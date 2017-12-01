# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class Sequel
      module Associations
        class OneToMany < Base
          def call(record)
            with_scope.each do |child|
              child_clone = clone_one(child)
              child_clone[:"#{reflection.foreign_key}"] = nil
              record.__send__(association_name) << child_clone
            end

            record
          end
        end
      end
    end
  end
end

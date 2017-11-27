# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      module Associations
        class HABTM < Base
          def call(record)
            with_scope.each do |child|
              child_clone = clone_one(child)
              record.__send__(association_name) << child_clone
            end

            record
          end
        end
      end
    end
  end
end

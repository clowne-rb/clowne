# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      module Associations
        class BelongsTo < Base
          def call(record)
            child = association
            return record unless child

            unless declaration.scope.nil?
              warn(
                "[Clowne] Belongs to association does not support scopes " \
                "(#{@association_name} for #{@source.class})"
              )
            end

            child_clone = clone_one(child)
            record.__send__(:"#{association_name}=", child_clone)
            record
          end
          # rubocop: enable Metrics/MethodLength
        end
      end
    end
  end
end

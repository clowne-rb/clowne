# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      module Associations
        class HasOne < Base
          # rubocop: disable Metrics/MethodLength
          def call(record)
            child = association
            return record unless child

            unless declaration.scope.nil?
              warn(
                "[Clowne] Has one association does not support scopes " \
                "(#{@association_name} for #{@source.class})"
              )
            end

            child_clone = clone_one(child)
            child_clone[:"#{reflection.foreign_key}"] = nil
            record.__send__(:"#{association_name}=", child_clone)

            record
          end
          # rubocop: enable Metrics/MethodLength
        end
      end
    end
  end
end

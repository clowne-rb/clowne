# frozen_string_literal: true

module Clowne
  module Adapters # :nodoc: all
    class ActiveRecord
      module Associations
        class Noop < Base
          def call(record)
            warn(
              "[Clowne] Reflection #{reflection.class.name} is not supported "\
              "(#{@association_name} for #{@source.class})"
            )
            record
          end
        end
      end
    end
  end
end

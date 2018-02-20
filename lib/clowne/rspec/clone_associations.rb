# frozen_string_literal: true

module Clowne
  module RSpec
    module Matchers
      # `clone_associations` matcher is just an extension of `contain_exactly` matcher
      class CloneAssociations < ::RSpec::Matchers::BuiltIn::ContainExactly
        include Clowne::RSpec::Helpers

        def convert_actual_to_an_array
          @actual = plan.declarations
            .select { |key, _| key == :association }
            .map { |_, decl| decl.name }
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include(Module.new do
    def clone_associations(*expected)
      Clowne::RSpec::Matchers::CloneAssociations.new(expected)
    end
  end, type: :cloner)
end

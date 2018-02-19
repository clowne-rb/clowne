# frozen_string_literal: true

module Clowne
  module RSpec
    module Matchers
      # `clone_associations` matcher is just an extension of `contain_exactly` matcher
      class CloneAssociations < ::RSpec::Matchers::BuiltIn::ContainExactly
        def with_traits(*traits)
          @traits = traits
          self
        end

        def convert_actual_to_an_array
          raise ArgumentError, non_cloner_message unless @actual <= ::Clowne::Cloner

          plan = @traits.nil? ? @actual.default_plan : @actual.plan_with_traits(@traits)

          @actual = plan.declarations
            .select { |key, _| key == :association }
            .map { |_, decl| decl.name }
        end

        private

        def non_cloner_message
          "expected a cloner to be passed to `expect(...)`, " \
          "but got #{actual_formatted}"
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
  end)
end

# frozen_string_literal: true

module Clowne
  module RSpec
    module Matchers
      class CloneAssociation < ::RSpec::Matchers::BuiltIn::BaseMatcher
        include Clowne::RSpec::Helpers

        AVAILABLE_PARAMS = %i[
          traits
          clone_with
          params
          scope
        ].freeze

        attr_reader :expected_params

        def initialize(name, options)
          @expected = name
          extract_options! options
        end

        def match(expected, _actual)
          @actual = plan.declarations
            .find { |key, decl| key == :association && decl.name == expected }

          return false if @actual.nil?

          @actual = actual.last

          AVAILABLE_PARAMS.each do |param|
            if expected_params[param] != UNDEFINED
              return false if expected_params[param] != actual.send(param)
            end
          end

          true
        end

        def does_not_match?(*)
          raise "This matcher doesn't support negation"
        end

        def failure_message
          if @actual.nil?
            "expected to include association #{expected}, but none found"
          else
            params_failure_message
          end
        end

        private

        def extract_options!(options)
          @expected_params = {}

          AVAILABLE_PARAMS.each do |param|
            expected_params[param] = options.fetch(param, UNDEFINED)
          end

          raise ArgumentError, "Lambda scope is not supported" if
            expected_params[:scope].is_a?(Proc)

          raise ArgumentError, "Lambda params is not supported" if
            expected_params[:params].is_a?(Proc)
        end

        def params_failure_message
          "expected :#{@expected} association " \
          "to have options #{formatted_expected_params}, " \
          "but got #{formatted_actual_params}"
        end

        def formatted_expected_params
          ::RSpec::Support::ObjectFormatter.format(
            expected_params.reject { |_, v| v == UNDEFINED }
          )
        end

        def formatted_actual_params
          actual_params = AVAILABLE_PARAMS.each_with_object({}) do |key, acc|
            acc[key] = actual.send(key)
          end
          ::RSpec::Support::ObjectFormatter.format(actual_params)
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include(Module.new do
    def clone_association(expected, **options)
      Clowne::RSpec::Matchers::CloneAssociation.new(expected, options)
    end
  end, type: :cloner)
end

# frozen_string_literal: true

# rubocop:disable  Metrics/BlockLength
::RSpec::Matchers.define :clone_association do |expected|
  chain :with_traits do |*traits|
    @traits = traits
  end

  match do |cloner|
    plan = @traits.nil? ? cloner.default_plan : cloner.plan_with_traits(@traits)

    plan_associations = plan.get(:association)

    true
  end

  match_when_negated do |_actual|
    raise "This matcher doesn't support negation"
  end

  failure_message do |_actual|

  end
end

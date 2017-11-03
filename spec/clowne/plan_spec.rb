RSpec.describe Clowne::Plan do
  describe '#validate!' do
    subject { plan.validate! }

    context 'when plan is valid' do
      let(:plan) { described_class.new }

      it { is_expected.to be_truthy }
    end

    context 'when plan is no valid' do
      let(:plan) do
        described_class.new.tap do |plan|
          plan.add('items', double)
          plan.add('items', double)
          plan.add('comments', double)
          plan.add('comments', double)
          plan.add('another_rel', double)
        end
      end

      it { expect { subject }.to raise_error(Clowne::ConfigurationError, 'You have duplicate configurations with keys: items, comments') }
    end
  end
end

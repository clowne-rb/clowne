RSpec.describe Clowne::ActiveRecordAdapter::Adapter do
  # subject { described_class.call(source, record, declaration) }
  describe '.reflections_for' do
    subject { described_class.reflections_for(Account.new) }

    it { is_expected.to eq(Account.reflections) }
  end
end

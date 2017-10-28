RSpec.describe Clowne::ActiveRecordAdapter::Adapter do
  # subject { described_class.call(source, record, declaration) }
  describe '.reflections_for' do
    subject { described_class.reflections_for(Account.new) }

    it { is_expected.to eq(Account.reflections) }
  end

  describe '.plain_clone' do
    let!(:account) { Account.create(title: 'Some title') }

    subject { described_class.plain_clone(account).as_json }

    it { is_expected.to eq(account.dup.as_json) }
  end
end

describe Clowne::Adapters::ActiveRecord do
  describe '.reflections_for' do
    subject { described_class.reflections_for(Account.new) }

    it { is_expected.to eq(Account.reflections) }
  end

  describe '.clone_record' do
    let(:account) { Account.new(title: 'Some title') }

    subject { described_class.new.clone_record(account).as_json }

    it { is_expected.to eq(account.dup.as_json) }
  end

  xdescribe '.resolve_declaration'
end

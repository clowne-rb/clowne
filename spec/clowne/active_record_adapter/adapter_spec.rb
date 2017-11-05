RSpec.describe Clowne::ActiveRecordAdapter::Adapter do
  describe '.reflections_for' do
    subject { described_class.reflections_for(Account.new) }

    it { is_expected.to eq(Account.reflections) }
  end

  describe '.plain_clone' do
    let!(:account) { Account.create(title: 'Some title') }

    subject { described_class.plain_clone(account).as_json }

    it { is_expected.to eq(account.dup.as_json) }
  end

  describe '.clone' do
    let!(:account) { Account.create(title: 'Some title') }
    let!(:history) { History.create(some_stuff: 'Some stuff', account: account) }

    subject { described_class.clone(account, plan, Clowne::Params.new({})) }

    context 'when plan is empty' do
      let(:plan) { double(Clowne::Plan.new, declarations: [])  }

      it { expect(subject.as_json).to eq(Account.new(title: 'Some title').as_json) }
    end

    context 'when plan has association directive' do
      let(:plan) { double(Clowne::Plan.new, declarations: [
        Clowne::Declarations::IncludeAssociation.new(:history)
      ]) }

      it 'duplicate history' do
        expect(subject.history.as_json).to eq(History.new(some_stuff: 'Some stuff').as_json)
      end
    end
  end
end

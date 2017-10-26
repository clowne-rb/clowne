RSpec.describe Clowne::ActiveRecordAdapter::CloneAssociation do
  describe 'has_one' do
    let(:account) { Account.create(title: 'Some account') }
    let(:source) { Post.create(account: account) }
    let(:record) { Post.new }

    subject { described_class.call(source, record, declaration) }

    context 'when simple has one association' do
      let(:declaration) { double(association: :account) }

      it "clone source's account" do
        expect(subject.account).to be_a(Account)
        expect(subject.account.title).to eq('Some account')
      end
    end
  end

  describe 'belongs_to (not supported)' do
    let(:topic) { Topic.create(title: 'Some post', description: 'Some description' ) }
    let(:source) { Post.create(topic: topic) }
    let(:record) { Post.new }
    let(:declaration) { double(association: :topic) }

    subject { described_class.call(source, record, declaration) }

    it 'return unchanged record' do
      expect(subject.topic).to be_nil
    end
  end
end

RSpec.describe Clowne::ActiveRecordAdapter::CloneAssociation do
  subject { described_class.call(source, record, declaration) }

  describe 'has_one' do
    let(:account) { Account.create(title: 'Some account') }
    let(:source) { Post.create(account: account) }
    let(:record) { Post.new }

    context 'when simple relation' do
      let(:declaration) { double(association: :account) }

      it "clone source's account" do
        expect(subject.account).to be_a(Account)
        expect(subject.account.title).to eq('Some account')
      end
    end

    context 'when through relation' do
      let(:history) { History.create(some_stuff: 'Some stuff', account: account) }
      let(:declaration) { double(association: :account) }

      it "clone source's account -> history" do
        pending 'Waiting nested cloners'
        cloned_history = subject.account.history
        expect(cloned_history).to be_a(History)
        expect(cloned_history.some_stuff).to eq('Some stuff')
      end
    end
  end

  # describe 'has_one through' do
  #   let(:history) { History.create(some_stuff: 'Some stuff') }
  #   let(:account) { Account.create(title: 'Some title') }
  #   let(:source) { Post.create(history: history) }
  #   let(:record) { Post.new }
  #   let(:declaration) { double(association: :history) }
  #
  #   subject { described_class.call(source, record, declaration) }
  #
  #   it "clone source's hisotry" do
  #     expect(subject.hisotry).to be_a(History)
  #     expect(subject.hisotry.some_stuff).to eq('Some stuff')
  #   end
  # end

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

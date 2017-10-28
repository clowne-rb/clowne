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

  describe 'has_many' do
    let(:source) { User.create }
    let(:record) { User.new }

    before { 2.times.collect { Post.create(owner: source, title: 'Some post') } }

    context 'when simple relation' do
      let(:declaration) { double(association: :posts) }

      it "clone source's posts" do
        expect(subject.posts.map(&:title)).to eq(['Some post', 'Some post'])
      end
    end
  end

  describe 'has_and_belongs_to_many' do
    let(:tags) { 2.times.collect { |i| Tag.create(value: "tag-#{i}") } }
    let(:source) { Post.create(tags: tags) }
    let(:record) { Post.new }

    let(:declaration) { double(association: :tags) }

    it "clone source's tags" do
      expect(subject.tags.map(&:value)).to eq(['tag-0', 'tag-1'])
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

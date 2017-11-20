describe Clowne::Adapters::ActiveRecord::Association, :cleanup do
  around(:each) { |ex| use_adapter(:active_record, &ex) }

  let(:params) { {} }

  subject { described_class.call(source, record, declaration, params) }

  describe 'has_one' do
    let(:account) { Account.create(title: 'Some account') }
    let(:source) { Post.create(account: account) }
    let(:record) { Post.new }

    context 'when simple relation' do
      let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:account) }

      it "clone source's account" do
        expect(subject.account).to be_a(Account)
        expect(subject.account.title).to eq('Some account')
      end
    end

    context 'when defined custom cloner on relation' do
      let(:account_custom_cloner) do
        Class.new(Clowne::Cloner) do
          include_association :history
        end
      end

      let!(:history) { History.create(some_stuff: 'Some stuff', account: account) }
      let(:declaration) do
        Clowne::Declarations::IncludeAssociation.new(:account, nil, clone_with: account_custom_cloner)
      end

      it "clone source's account -> history" do
        cloned_history = subject.account.history
        expect(cloned_history).to be_a(History)
        expect(cloned_history.some_stuff).to eq('Some stuff')
      end
    end
  end

  describe 'has_many' do
    let(:source) { User.create }
    let(:record) { User.new }

    before { Array.new(2) { Post.create(owner: source, title: 'Some post') } }

    context 'when simple relation' do
      let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:posts) }

      it "clone source's posts" do
        expect(subject.posts.map(&:title)).to eq(['Some post', 'Some post'])
      end
    end

    context 'when defined scope on relation' do
      let!(:selected_post) { Post.create(owner: source, title: 'Selected post') }

      let(:declaration) do
        Clowne::Declarations::IncludeAssociation.new(:posts, proc { where.not(title: 'Some post') })
      end

      it 'clone only selected post' do
        expect(subject.posts.map(&:title)).to eq(['Selected post'])
      end
    end
  end

  describe 'has_and_belongs_to_many' do
    let(:tags) { Array.new(2) { |i| Tag.create(value: "tag-#{i}") } }
    let(:source) { Post.create(tags: tags) }
    let(:record) { Post.new }

    let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:tags) }

    it "clone source's tags" do
      expect(subject.tags.map(&:value)).to eq(['tag-0', 'tag-1'])
    end
  end

  describe 'belongs_to (not supported)' do
    let(:topic) { Topic.create(title: 'Some post', description: 'Some description') }
    let(:source) { Post.create(topic: topic) }
    let(:record) { Post.new }
    let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:topic) }

    it 'return unchanged record' do
      expect(subject.topic).to be_nil
    end
  end
end

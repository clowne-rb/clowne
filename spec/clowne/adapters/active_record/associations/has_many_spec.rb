describe Clowne::Adapters::ActiveRecord::Associations::HasMany, :cleanup do
  let(:source) { create(:user, :with_posts, posts_num: 2) }
  let(:record) { User.new }
  let(:reflection) { User.reflections['posts'] }
  let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:posts) }
  let(:params) { {} }
  let(:traits) { [] }

  subject(:resolver) { described_class.new(reflection, source, declaration, params, traits) }

  around(:each) { |ex| use_adapter(:active_record, &ex) }

  before(:all) do
    class PostCloner < Clowne::Cloner
      finalize do |_source, record, params|
        record.topic_id = params[:topic_id] if params[:topic_id]
      end

      nullify :topic_id, :owner_id

      trait :mark_as_clone do
        finalize do |source, record|
          record.title = source.title + ' (Cloned)'
        end
      end
    end
  end

  after(:all) { Object.send(:remove_const, 'PostCloner') }

  describe '.call' do
    subject { resolver.call(record) }

    it 'infers default cloner from model name' do
      expect(subject.posts.size).to eq 2
      expect(subject.posts.first).to have_attributes(
        owner_id: nil,
        topic_id: nil,
        title: source.posts.first.title,
        contents: source.posts.first.contents
      )
      expect(subject.posts.second).to have_attributes(
        owner_id: nil,
        topic_id: nil,
        title: source.posts.second.title,
        contents: source.posts.second.contents
      )
    end

    context 'with params' do
      let(:params) { { topic_id: 123 } }

      it 'pass params to child cloner' do
        expect(subject.posts.size).to eq 2
        expect(subject.posts.first).to have_attributes(
          owner_id: nil,
          topic_id: 123
        )
        expect(subject.posts.second).to have_attributes(
          owner_id: nil,
          topic_id: 123
        )
      end
    end

    xcontext 'with traits' do
      let(:traits) { [:mark_as_clone] }

      it 'pass traits to child cloner' do
        expect(subject.posts.size).to eq 2
        expect(subject.posts.first).to have_attributes(
          owner_id: nil,
          topic_id: nil,
          title: "#{source.posts.first.title} (Cloned)"
        )
        expect(subject.posts.second).to have_attributes(
          owner_id: nil,
          topic_id: nil,
          title: "#{source.posts.second.title} (Cloned)"
        )
      end
    end

    context 'with custom cloner' do
      let(:source) do
        create(:user).tap do |u|
          create(:post, title: 'Some post', owner: u)
        end
      end

      let(:post_cloner) do
        Class.new(Clowne::Cloner) do
          finalize do |source, record, _params|
            record.title = "Copy of #{source.title}"
          end
        end
      end

      let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:posts, clone_with: post_cloner) }

      it 'applies custom cloner' do
        expect(subject.posts.size).to eq 1
        expect(subject.posts.first).to have_attributes(
          owner_id: nil,
          topic_id: source.posts.first.topic_id,
          title: 'Copy of Some post'
        )
      end
    end
  end
end

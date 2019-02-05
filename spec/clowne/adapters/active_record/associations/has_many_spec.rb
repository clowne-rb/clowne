describe Clowne::Adapters::ActiveRecord::Associations::HasMany, :cleanup, adapter: :active_record do
  let(:adapter) { double }
  let(:source) { create(:user, :with_posts, posts_num: 2) }
  let(:record) { AR::User.new }
  let(:reflection) { AR::User.reflections['posts'] }
  let(:scope) { {} }
  let(:declaration_params) { {} }
  let(:declaration) do
    Clowne::Declarations::IncludeAssociation.new(:posts, scope, **declaration_params)
  end
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, double, params) }

  before(:all) do
    module AR
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
  end

  after(:all) { AR.send(:remove_const, 'PostCloner') }

  describe '.call' do
    subject { Clowne::Utils::Operation.wrap { resolver.call(record) }.to_record }

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
      let(:declaration_params) { { params: true } }
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

    context 'with scope' do
      context 'block scope' do
        let(:scope) { ->(params) { where(title: params[:title]) if params[:title] } }
        let(:params) { { title: source.posts.first.title } }

        it 'clones scoped children' do
          expect(subject.posts.size).to eq 1
          expect(subject.posts.first).to have_attributes(
            owner_id: nil,
            title: source.posts.first.title
          )
        end

        context 'when block is no-op' do
          let(:params) { {} }

          it 'clones all children' do
            expect(subject.posts.size).to eq 2
          end
        end
      end

      context 'symbol scope' do
        let(:scope) { :alpha_first }

        let(:post1) { source.posts.first }
        let(:post2) { source.posts.second }

        before do
          post1.update! title: 'Zadyza'
          post2.update! title: 'Ta-dam'
        end

        it 'clones scoped children' do
          expect(subject.posts.size).to eq 1
          expect(subject.posts.first).to have_attributes(
            owner_id: nil,
            title: 'Ta-dam'
          )
        end
      end
    end

    context 'with traits' do
      let(:declaration_params) { { traits: :mark_as_clone } }

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

      let(:declaration_params) { { clone_with: post_cloner } }

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

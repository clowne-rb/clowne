describe Clowne::Adapters::ActiveRecord::CloneAssociation, :cleanup do
  around(:each) { |ex| use_adapter(:active_record, &ex) }

  let(:object) { described_class.new(source, declaration, params) }
  let(:params) { {} }
  let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:posts) }

  describe '#association' do
    let(:posts) { Array.new(2) { Post.create } }
    let(:source) { User.create(posts: posts) }

    subject { object.association }

    it { is_expected.to eq(posts) }
  end

  describe '#reflection' do
    let(:source) { User.new }

    subject { object.reflection }

    it { is_expected.to eq(User.reflections['posts']) }
  end

  describe '#clone_with' do
    let(:post) { Post.create(title: 'Some post') }
    let(:source) { User.create(posts: [post]) }

    subject { object.clone_with(post).as_json }

    context 'when custom cloner is not defined' do
      it { is_expected.to eq(post.dup.as_json) }
    end

    context 'when has custom cloner' do
      let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:posts, nil, clone_with: post_cloner) }
      let(:post_cloner) do
        Class.new(Clowne::Cloner) do
          finalize do |_source, record, _params|
            record.title = 'Another post'
          end
        end
      end

      it 'change title' do
        post.title = 'Another post'
        expect(subject).to eq(post.dup.as_json)
      end
    end
  end

  describe '#with_scope' do
    let(:post1) { Post.create(title: 'Some post') }
    let(:post2) { Post.create(title: 'Foo') }
    let(:source) { User.create(posts: [post1, post2]) }

    subject { object.with_scope.map(&:title) }

    context 'when scope is a Proc' do
      let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:posts, proc { where(title: 'Foo') }) }

      it { is_expected.to eq(['Foo']) }
    end

    context 'when scope is a Proc with params' do
      let(:declaration) do
        Clowne::Declarations::IncludeAssociation.new(:posts, proc { |params| where(title: params[:title]) })
      end

      context 'title of not exists post' do
        let(:params) { { title: 'I am not exists post' } }

        it { is_expected.to be_empty }
      end

      context 'title of Foo post' do
        let(:params) { { title: 'Foo' } }

        it { is_expected.to eq(['Foo']) }
      end
    end

    context 'when scope is a Symbol' do
      let(:declaration) { Clowne::Declarations::IncludeAssociation.new(:posts, :default_posts) }

      before do
        Post.class_eval do
          scope :default_posts, -> { where(title: 'Some post') }
        end
      end

      it { is_expected.to eq(['Some post']) }
    end
  end
end

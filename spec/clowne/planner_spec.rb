RSpec.describe Clowne::Planner do
  describe 'compile' do
    let(:object) { double(reflections: {"users" => nil, "posts" => nil}) }

    subject { described_class.compile(cloner, object).values }

    context 'when cloner with one included association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          include_association :users
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::IncludeAssociation, {name: :users} ]
      ]) }
    end

    context 'when cloner with include_all declaration' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          include_all
          include_association :users
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::IncludeAssociation, {name: :users, options: {}} ],
        [ Clowne::Declarations::IncludeAssociation, {name: :posts} ]
      ]) }
    end

    context 'when cloner with include_all and redefined association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          include_all
          include_association :users, clone_with: 'AnotherCloner'
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::IncludeAssociation, {name: :users, options: {clone_with: 'AnotherCloner'}} ],
        [ Clowne::Declarations::IncludeAssociation, {name: :posts} ]
      ]) }
    end

    context 'when cloner with include_all and excuding association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          include_all
          exclude_association :users
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::IncludeAssociation, {name: :posts} ]
      ]) }
    end

    context 'when cloner with nullify declaration' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          nullify :foo
          nullify :bar
          nullify :baz
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::Nullify, {attributes: [:baz]} ]
      ]) }
    end

    context 'when cloner with finalize declaration' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          finalize &Proc.new { 1 + 1 }
          finalize &Proc.new { 1 + 2 }
          finalize &Proc.new { 1 + 3 }
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 3 }} ]
      ]) }
    end

    context 'when cloner with context' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          include_association :users
          include_association :posts

          finalize &Proc.new { 1 + 1 }

          context :with_brands do
            include_association :brands
            exclude_association :posts

            finalize &Proc.new { 1 + 2 }
          end
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::IncludeAssociation, {name: :users} ],
        [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 2 }} ],
        [ Clowne::Declarations::IncludeAssociation, {name: :brands} ]
      ]) }
    end
  end
end

RSpec.describe Clowne::Planner do
  describe 'compile' do
    let(:object) { double(reflections: {"users" => nil, "posts" => nil}) }
    let(:options) { {} }

    subject { described_class.compile(cloner, object, **options).declarations }

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
        [ Clowne::Declarations::IncludeAssociation, {name: :users} ],
        [ Clowne::Declarations::IncludeAssociation, {name: :posts} ],
        [ Clowne::Declarations::IncludeAssociation, {name: :users, options: {}} ]
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
        [ Clowne::Declarations::IncludeAssociation, {name: :users} ],
        [ Clowne::Declarations::IncludeAssociation, {name: :posts} ],
        [ Clowne::Declarations::IncludeAssociation, {name: :users, options: {clone_with: 'AnotherCloner'}} ]
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
        [ Clowne::Declarations::Nullify, {attributes: [:foo, :bar, :baz]} ]
      ]) }

      context 'when cloner with main nullify declaration and with trait' do
        let(:cloner) do
          Class.new(Clowne::Cloner) do
            adapter FakeAdapter
            nullify :foo

            trait :with_nullify do
              nullify :bar
            end
          end
        end

        let(:options) { { traits: [:with_nullify] } }

        it { is_expected.to be_a_declarations([
          [ Clowne::Declarations::Nullify, {attributes: [:foo, :bar]} ]
        ]) }
      end
    end

    context 'when cloner with finalize declaration' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          finalize &Proc.new { 1 + 1 }
          finalize &Proc.new { 1 + 2 }
        end
      end

      it { is_expected.to be_a_declarations([
        [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 1 }} ],
        [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 2 }} ]
      ]) }

      context 'when cloner with main finalize declaration and with trait' do
        let(:cloner) do
          Class.new(Clowne::Cloner) do
            adapter FakeAdapter
            finalize &Proc.new { 1 + 3 }

            trait :with_finalize do
              finalize &Proc.new { 1 + 4 }
            end
          end
        end

        let(:options) { { traits: :with_finalize } }

        it { is_expected.to be_a_declarations([
          [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 3 }} ],
          [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 4 }} ]
        ]) }
      end
    end

    describe 'traits' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          include_association :users
          include_association :posts

          finalize &Proc.new { 1 + 1 }

          trait :with_brands do
            include_association :brands
            exclude_association :posts

            finalize &Proc.new { 1 + 2 }
          end
        end
      end

      context 'when planing without traits' do
        it { is_expected.to be_a_declarations([
          [ Clowne::Declarations::IncludeAssociation, {name: :users} ],
          [ Clowne::Declarations::IncludeAssociation, {name: :posts} ],
          [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 1 }} ]
        ]) }
      end

      context 'when one trait is active' do
        let(:options) { { traits: [:with_brands] } }

        it { is_expected.to be_a_declarations([
          [ Clowne::Declarations::IncludeAssociation, {name: :users} ],
          [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 1 }} ],
          [ Clowne::Declarations::IncludeAssociation, {name: :brands} ],
          [ Clowne::Declarations::Finalize, {block: Proc.new { 1 + 2 }} ]
        ]) }
      end
    end
  end
end

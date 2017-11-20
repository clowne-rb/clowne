describe Clowne::Planner do
  describe '.compile' do
    let(:object) { double(reflections: { 'users' => nil, 'posts' => nil }) }
    let(:options) { {} }

    subject { described_class.compile(cloner, object, **options).declarations }

    context 'when cloner with one included association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_association :users
        end
      end

      it 'matches declarations' do
        is_expected.to match_declarations(
          [[Clowne::Declarations::IncludeAssociation, { name: :users }]]
        )
      end
    end

    context 'when cloner with include_all declaration' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_all
          include_association :users
        end
      end

      it 'matches declarations' do
        is_expected.to match_declarations(
          [
            [Clowne::Declarations::IncludeAssociation, { name: :users }],
            [Clowne::Declarations::IncludeAssociation, { name: :posts }],
            [Clowne::Declarations::IncludeAssociation, { name: :users, options: {} }]
          ]
        )
      end
    end

    context 'when cloner with include_all and redefined association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_all
          include_association :users, clone_with: 'AnotherCloner'
        end
      end

      it 'matches declarations' do
        is_expected.to match_declarations(
          [
            [Clowne::Declarations::IncludeAssociation, { name: :users }],
            [Clowne::Declarations::IncludeAssociation, { name: :posts }],
            [Clowne::Declarations::IncludeAssociation, {
              name: :users,
              options: { clone_with: 'AnotherCloner' }
            }]
          ]
        )
      end
    end

    context 'when cloner with include_all and excuding association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_all
          exclude_association :users
        end
      end

      it 'matches declarations' do
        is_expected.to match_declarations(
          [[Clowne::Declarations::IncludeAssociation, { name: :posts }]]
        )
      end
    end

    context 'when cloner with nullify declaration' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          nullify :foo
          nullify :bar
          nullify :baz
        end
      end

      it 'matches declarations' do
        is_expected.to match_declarations(
          [[Clowne::Declarations::Nullify, { attributes: %i[foo bar baz] }]]
        )
      end

      context 'when cloner with main nullify declaration and with trait' do
        let(:cloner) do
          Class.new(Clowne::Cloner) do
            nullify :foo

            trait :with_nullify do
              nullify :bar
            end
          end
        end

        let(:options) { { traits: [:with_nullify] } }

        it 'matches declarations' do
          is_expected.to match_declarations(
            [[Clowne::Declarations::Nullify, { attributes: %i[foo bar] }]]
          )
        end
      end
    end

    context 'when cloner with finalize declaration' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          finalize(&proc { 1 + 1 })
          finalize(&proc { 1 + 2 })
        end
      end

      it 'matches declarations' do
        is_expected.to match_declarations(
          [
            [Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
            [Clowne::Declarations::Finalize, { block: proc { 1 + 2 } }]
          ]
        )
      end

      context 'when cloner with main finalize declaration and with trait' do
        let(:cloner) do
          Class.new(Clowne::Cloner) do
            finalize(&proc { 1 + 3 })

            trait :with_finalize do
              finalize(&proc { 1 + 4 })
            end
          end
        end

        let(:options) { { traits: :with_finalize } }

        it 'matches declarations' do
          is_expected.to match_declarations(
            [
              [Clowne::Declarations::Finalize, { block: proc { 1 + 3 } }],
              [Clowne::Declarations::Finalize, { block: proc { 1 + 4 } }]
            ]
          )
        end
      end
    end

    describe 'traits' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_association :users
          include_association :posts

          finalize(&proc { 1 + 1 })

          trait :with_brands do
            include_association :brands
            exclude_association :posts

            finalize(&proc { 1 + 2 })
          end
        end
      end

      context 'when planing without traits' do
        it 'matches declarations' do
          is_expected.to match_declarations(
            [
              [Clowne::Declarations::IncludeAssociation, { name: :users }],
              [Clowne::Declarations::IncludeAssociation, { name: :posts }],
              [Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }]
            ]
          )
        end
      end

      context 'when one trait is active' do
        let(:options) { { traits: [:with_brands] } }

        it 'matches declarations' do
          is_expected.to match_declarations(
            [
              [Clowne::Declarations::IncludeAssociation, { name: :users }],
              [Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
              [Clowne::Declarations::IncludeAssociation, { name: :brands }],
              [Clowne::Declarations::Finalize, { block: proc { 1 + 2 } }]
            ]
          )
        end
      end
    end
  end
end

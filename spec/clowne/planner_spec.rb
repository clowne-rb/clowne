describe Clowne::Planner, adapter: :active_record do
  describe '.compile' do
    let(:options) { {} }

    subject { described_class.compile(cloner, **options).declarations }

    context 'when cloner with one included association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_association :users
        end
      end

      specify do
        is_expected.to match_declarations(
          [[:association, Clowne::Declarations::IncludeAssociation, { name: :users }]]
        )
      end
    end

    context 'when cloner with include_all declaration after include_association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_association :users
          include_all
        end
      end

      specify do
        is_expected.to match_declarations(
          [[:all_associations, Clowne::Declarations::IncludeAll]]
        )
      end
    end

    context 'when cloner with include_all declaration before include_association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_all
          include_association :users
        end
      end

      specify do
        is_expected.to match_declarations(
          [[:association, Clowne::Declarations::IncludeAssociation, { name: :users }]]
        )
      end
    end

    context 'when cloner with include_all and exclude_association' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_all
          exclude_association :users
        end
      end

      specify do
        is_expected.to match_declarations(
          [[:all_associations, Clowne::Declarations::IncludeAll, { excludes: Set.new(['users']) }]]
        )
      end
    end

    context 'when cloner with nullify declarations' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          nullify :foo, :bar
          nullify :baz
        end
      end

      specify do
        is_expected.to match_declarations(
          [
            [:nullify, Clowne::Declarations::Nullify, { attributes: %i[foo bar] }],
            [:nullify, Clowne::Declarations::Nullify, { attributes: %i[baz] }]
          ]
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

        specify do
          is_expected.to match_declarations(
            [
              [:nullify, Clowne::Declarations::Nullify, { attributes: %i[foo] }],
              [:nullify, Clowne::Declarations::Nullify, { attributes: %i[bar] }]
            ]
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

      specify do
        is_expected.to match_declarations(
          [
            [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
            [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 2 } }]
          ]
        )
      end
    end

    context 'when multiple traits' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          include_associations :users, :posts

          finalize(&proc { 1 + 1 })

          trait :with_brands do
            include_association :brands
            exclude_association :posts

            finalize(&proc { 1 + 2 })
          end

          trait :clear_fields do
            nullify :extra, :data, :meta
          end

          trait :with_all do
            include_all
          end
        end
      end

      context 'when planing without traits' do
        specify do
          is_expected.to match_declarations(
            [
              [:association, Clowne::Declarations::IncludeAssociation, { name: :users }],
              [:association, Clowne::Declarations::IncludeAssociation, { name: :posts }],
              [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }]
            ]
          )
        end
      end

      context 'when one trait is active' do
        let(:options) { { traits: [:with_brands] } }

        specify do
          is_expected.to match_declarations(
            [
              [:association, Clowne::Declarations::IncludeAssociation, { name: :users }],
              [:association, Clowne::Declarations::IncludeAssociation, { name: :brands }],
              [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
              [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 2 } }]
            ]
          )
        end
      end

      context 'when all traits are active' do
        let(:options) { { traits: [:with_brands, :clear_fields, :with_all] } }

        specify do
          is_expected.to match_declarations(
            [
              [:all_associations, Clowne::Declarations::IncludeAll],
              [:nullify, Clowne::Declarations::Nullify, { attributes: %i[extra data meta] }],
              [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
              [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 2 } }]
            ]
          )
        end
      end

      context 'when inherited cloner' do
        let(:new_cloner) do
          Class.new(cloner) do
            include_association :files

            trait :clear_fields do
              nullify :files_cache
            end
          end
        end

        subject { described_class.compile(new_cloner, **options).declarations }

        let(:options) { { traits: [:with_brands, :clear_fields] } }

        specify do
          is_expected.to match_declarations(
            [
              [:association, Clowne::Declarations::IncludeAssociation, { name: :users }],
              [:association, Clowne::Declarations::IncludeAssociation, { name: :files }],
              [:association, Clowne::Declarations::IncludeAssociation, { name: :brands }],
              [:nullify, Clowne::Declarations::Nullify, { attributes: %i[extra data meta] }],
              [:nullify, Clowne::Declarations::Nullify, { attributes: %i[files_cache] }],
              [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
              [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 2 } }]
            ]
          )
        end
      end
    end
  end
end

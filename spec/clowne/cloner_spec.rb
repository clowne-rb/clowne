describe Clowne::Cloner do
  let(:cloner) do
    Class.new(described_class) do
      adapter FakeAdapter

      include_all

      include_association :comments
      include_association :posts, :some_scope, clone_with: 'AnotherClonerClass'
      include_association :tags, clone_with: 'AnotherCloner2Class'

      exclude_association :users

      nullify :title, :description

      finalize do |_source, _record, _params|
        1 + 1
      end

      trait :with_brands do
        include_association :brands
      end
    end
  end

  let(:expected_declarations) do
    [
      [Clowne::Declarations::IncludeAll, {}],
      [Clowne::Declarations::IncludeAssociation, { name: :comments, scope: nil, options: {} }],
      [Clowne::Declarations::IncludeAssociation, {
        name: :posts,
        scope: :some_scope,
        options: { clone_with: 'AnotherClonerClass' }
      }],
      [Clowne::Declarations::IncludeAssociation, {
        name: :tags,
        scope: nil,
        options: { clone_with: 'AnotherCloner2Class' }
      }],
      [Clowne::Declarations::ExcludeAssociation, { name: :users }],
      [Clowne::Declarations::Nullify, { attributes: %i[title description] }],
      [Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
      [Clowne::Declarations::Trait, { name: :with_brands, block: proc {} }]
    ]
  end

  describe 'DSL and Configuration' do
    it 'configure cloner', :aggregate_failures do
      expect(cloner.adapter).to eq(FakeAdapter)
      expect(cloner.config).to be_a(Clowne::Configuration)

      declarations = cloner.config.declarations

      expect(declarations).to match_declarations(expected_declarations)
    end
  end

  describe 'call wrong cloner' do
    context 'when adapter not defined' do
      let(:cloner) { Class.new(Clowne::Cloner) }

      it 'raise ConfigurationError' do
        expect { cloner.call(double) }.to raise_error(Clowne::ConfigurationError, 'Adapter is not defined')
      end
    end

    context 'when object is nil' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
        end
      end

      it 'raise UnprocessableSourceError' do
        expect { cloner.call(nil) }.to raise_error(
          Clowne::UnprocessableSourceError,
          'Nil is not cloneable object'
        )
      end
    end

    context 'when duplicate configurations' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter
          include_association :comments
          include_association :comments
        end
      end

      it 'raise ConfigurationError' do
        expect { cloner.call(double) }.to raise_error(
          Clowne::ConfigurationError,
          'You have duplicate keys in configuration: comments'
        )
      end
    end
  end

  describe 'inheritance' do
    context 'when cloner child of another cloner' do
      let(:cloner2) { Class.new(cloner) }

      it 'child cloner settings', :aggregate_failures do
        expect(cloner2.adapter).to eq(FakeAdapter)
        expect(cloner2.config).to be_a(Clowne::Configuration)

        declarations = cloner2.config.declarations

        expect(declarations).to match_declarations(expected_declarations)
      end
    end

    context 'when child cloner has own declaration' do
      let(:cloner2) do
        Class.new(cloner) do
          trait :child_cloner_trait do
          end
        end
      end

      it 'child and parent declarations' do
        expect(cloner2.config.declarations).to match_declarations(expected_declarations + [
          [Clowne::Declarations::Trait, { name: :child_cloner_trait, block: proc {} }]
        ])

        expect(cloner.config.declarations).to match_declarations(expected_declarations)
      end
    end
  end
end

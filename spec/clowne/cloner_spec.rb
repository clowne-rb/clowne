RSpec.describe Clowne::Cloner do
  class SomeCloner < described_class
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

  let(:expected_declarations) do
    [
      [Clowne::Declarations::IncludeAll, {}],
      [Clowne::Declarations::IncludeAssociation, {name: :comments, scope: nil, options: {}}],
      [Clowne::Declarations::IncludeAssociation, {name: :posts, scope: :some_scope, options: {clone_with: 'AnotherClonerClass'}}],
      [Clowne::Declarations::IncludeAssociation, {name: :tags, scope: nil, options: {clone_with: 'AnotherCloner2Class'}}],
      [Clowne::Declarations::ExcludeAssociation, {name: :users}],
      [Clowne::Declarations::Nullify, {attributes: [:title, :description]}],
      [Clowne::Declarations::Finalize, {block: Proc.new { 1 + 1 } }],
      [Clowne::Declarations::Trait, {name: :with_brands, block: Proc.new {} }]
    ]
  end

  describe 'DSL and Configuration' do
    it 'configure cloner' do
      expect(SomeCloner.adapter).to eq(FakeAdapter)
      expect(SomeCloner.config).to be_a(Clowne::Configuration)

      declarations = SomeCloner.config.declarations

      expect(declarations).to be_a_declarations(expected_declarations)
    end
  end

  describe 'call wrong cloner' do
    context 'when adapter not defined' do
      let(:cloner) { Class.new(Clowne::Cloner) }

      it { expect{ cloner.call(double) }.to raise_error(Clowne::ConfigurationError, 'Adapter is not defined') }
    end

    context 'when object is nil' do
      let(:cloner) { Class.new(Clowne::Cloner) do
        adapter FakeAdapter
      end }

      it { expect{ cloner.call(nil) }.to raise_error(Clowne::UnprocessableSourceError, 'Nil is not cloneable object') }
    end

    context 'when duplicate configurations' do
      let(:cloner) { Class.new(Clowne::Cloner) do
        adapter FakeAdapter
        include_association :comments
        include_association :comments
      end }

      it { expect{ cloner.call(double) }.to raise_error(Clowne::ConfigurationError, 'You have duplicate keys in configuration: comments') }
    end
  end

  describe 'inheritance' do
    context 'when cloner child of another cloner' do
      class Some2Cloner < SomeCloner; end

      it 'child cloner settings' do
        expect(Some2Cloner.adapter).to eq(FakeAdapter)
        expect(Some2Cloner.config).to be_a(Clowne::Configuration)

        declarations = Some2Cloner.config.declarations

        expect(declarations).to be_a_declarations(expected_declarations)
      end
    end

    context 'when child cloner has own declaration' do
      class Some3Cloner < SomeCloner
        trait :child_cloner_trait do
        end
      end

      it 'child declarations' do
        declarations = Some3Cloner.config.declarations

        expect(declarations).to be_a_declarations(expected_declarations + [
          [Clowne::Declarations::Trait, {name: :child_cloner_trait, block: Proc.new {} }]
        ])
      end

      it 'parent declarations does not change' do
        declarations = SomeCloner.config.declarations
        expect(declarations).to be_a_declarations(expected_declarations)
      end
    end
  end
end

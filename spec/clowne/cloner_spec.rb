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

  describe 'DSL and Configuration' do
    it 'configure cloner' do
      expect(SomeCloner.adapter).to eq(FakeAdapter)
      expect(SomeCloner.config).to be_a(Clowne::Configuration)

      config = SomeCloner.config.config

      expect(config).to be_a_declarations([
        [Clowne::Declarations::IncludeAll, {}],
        [Clowne::Declarations::IncludeAssociation, {name: :comments, scope: nil, options: {}}],
        [Clowne::Declarations::IncludeAssociation, {name: :posts, scope: :some_scope, options: {clone_with: 'AnotherClonerClass'}}],
        [Clowne::Declarations::IncludeAssociation, {name: :tags, scope: nil, options: {clone_with: 'AnotherCloner2Class'}}],
        [Clowne::Declarations::ExcludeAssociation, {name: :users}],
        [Clowne::Declarations::Nullify, {attributes: [:title, :description]}],
        [Clowne::Declarations::Finalize, {block: Proc.new { 1 + 1 } }],
        [Clowne::Declarations::Trait, {name: :with_brands, block: Proc.new {} }]
      ])
    end
  end

  describe 'call wrong cloner' do
    context 'when adapter not defined' do
      let(:cloner) { Class.new(Clowne::Cloner) }

      it { expect{ cloner.call(double) }.to raise_error(Clowne::Cloner::ConfigurationError, 'Adapter is not defined') }
    end

    context 'when object is nil' do
      let(:cloner) { Class.new(Clowne::Cloner) do
        adapter FakeAdapter
      end }

      it { expect{ cloner.call(nil) }.to raise_error(Clowne::Cloner::ConfigurationError, 'Nil is not cloneable object') }
    end
  end
end

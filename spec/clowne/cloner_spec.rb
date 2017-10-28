RSpec.describe Clowne::Cloner do
  class SomeCloner < described_class
    adapter FakeAdapter

    include_all

    include_association :comments
    include_association :posts, :some_scope, clone_with: 'AnotherClonerClass'

    exclude_association :users

    nullify :title, :description

    finalize do |_source, _record, _params|
      1 + 1
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
        [Clowne::Declarations::ExcludeAssociation, {name: :users}],
        [Clowne::Declarations::Nullify, {attributes: [:title, :description]}],
        [Clowne::Declarations::Finalize, {block: Proc.new { 1 + 1} }]
      ])
    end
  end
end

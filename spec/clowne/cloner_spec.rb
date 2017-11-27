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

      trait :without_comments do
        exclude_association :comments
      end
    end
  end

  let(:expected_plan) do
    [
      [:association, Clowne::Declarations::IncludeAssociation, {
        name: :comments, scope: nil, options: {}
      }],
      [:association, Clowne::Declarations::IncludeAssociation, {
        name: :posts,
        scope: :some_scope,
        options: { clone_with: 'AnotherClonerClass' }
      }],
      [:association, Clowne::Declarations::IncludeAssociation, {
        name: :tags,
        scope: nil,
        options: { clone_with: 'AnotherCloner2Class' }
      }],
      [:nullify, Clowne::Declarations::Nullify, { attributes: %i[title description] }],
      [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }]
    ]
  end

  describe '.default_plan' do
    it 'compiles plan once', :aggregate_failures do
      plan = cloner.default_plan

      expect(plan.declarations).to match_declarations(expected_plan)

      expect(cloner.default_plan).to equal(plan)
    end
  end

  describe '.plan_with_traits' do
    let(:expected_plan) do
      [
        [:association, Clowne::Declarations::IncludeAssociation, {
          name: :posts,
          scope: :some_scope,
          options: { clone_with: 'AnotherClonerClass' }
        }],
        [:association, Clowne::Declarations::IncludeAssociation, {
          name: :tags,
          scope: nil,
          options: { clone_with: 'AnotherCloner2Class' }
        }],
        [:association, Clowne::Declarations::IncludeAssociation, {
          name: :brands, scope: nil, options: {}
        }],
        [:nullify, Clowne::Declarations::Nullify, { attributes: %i[title description] }],
        [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }]
      ]
    end

    it 'compiles plan for traits once', :aggregate_failures do
      plan = cloner.plan_with_traits([:with_brands, :without_comments])

      expect(plan.declarations).to match_declarations(expected_plan)

      expect(cloner.plan_with_traits([:with_brands, :without_comments])).to equal(plan)
    end
  end

  describe '.call' do
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

    context 'when trait is unknown' do
      let(:cloner) do
        Class.new(Clowne::Cloner) do
          adapter FakeAdapter

          trait :with_comments do
            include_association :comments
          end
        end
      end

      it 'raise ConfigurationError' do
        expect { cloner.call(double, traits: [:without_comments]) }.to raise_error(
          Clowne::ConfigurationError,
          'Trait not found: without_comments'
        )
      end
    end
  end
end

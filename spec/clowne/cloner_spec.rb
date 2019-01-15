describe Clowne::Cloner do
  let(:cloner) do
    Class.new(described_class) do
      adapter :active_record

      include_association :comments
      include_association :posts, :some_scope, clone_with: 'AnotherClonerClass'
      include_association :tags, clone_with: 'AnotherCloner2Class'

      exclude_association :users
      include_association :users

      nullify :title, :description

      finalize do |_source, _record, _params|
        1 + 1
      end

      after_persist do |_source, _record, _params|
        2 + 2
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
      [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
      [:after_persist, Clowne::Declarations::AfterPersist, { block: proc { 2 + 2 } }]
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
        [:finalize, Clowne::Declarations::Finalize, { block: proc { 1 + 1 } }],
        [:after_persist, Clowne::Declarations::AfterPersist, { block: proc { 2 + 2 } }]
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
          adapter :base
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
          adapter :active_record

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

    context 'with inline config' do
      let(:source_class) { Struct.new(:name, :age) }

      let(:source) { source_class.new('John', 28) }

      let(:cloner) do
        Class.new(Clowne::Cloner) do
          finalize { |_, record| record.age += 1 }
        end
      end

      it 'works', :aggregate_failures do
        inlined = cloner.call(source) do
          nullify :name

          finalize { |_, record| record.age *= 2 }
        end

        expect(inlined).to have_attributes(
          name: nil,
          age: 58
        )

        cloned = cloner.call(source)

        expect(cloned).to have_attributes(
          name: 'John',
          age: 29
        )
      end
    end
  end

  describe '.partial_apply', :aggregate_failures do
    let(:cloner) do
      Class.new(Clowne::Cloner) do
        adapter :active_record

        nullify :rating

        trait :without_name do
          nullify :name
        end

        trait :copy do
          init_as { |_, target:, **| target }
        end

        finalize { |_, record, coef: 2, **| record.age *= coef }
      end
    end

    let(:source_class) { Struct.new(:name, :age, :rating) }

    let(:source) { source_class.new('John', 28, 99) }

    specify 'one action' do
      cloned = cloner.partial_apply(:nullify, source).to_record
      expect(cloned.age).to eq 28
      expect(cloned.rating).to be_nil
      expect(cloned.name).to eq 'John'
    end

    specify 'with traits' do
      cloned = cloner.partial_apply(:nullify, source, traits: :without_name).to_record
      expect(cloned.age).to eq 28
      expect(cloned.rating).to be_nil
      expect(cloned.name).to be_nil
    end

    specify 'with params' do
      cloned = cloner.partial_apply(:finalize, source, coef: 3).to_record
      expect(cloned.age).to eq 84
      expect(cloned.rating).to eq 99
      expect(cloned.name).to eq 'John'
    end

    specify 'multiple actions' do
      another = source_class.new('Jack', 33, 1)
      cloned = cloner.partial_apply(
        [:init_as, :finalize], source,
        traits: :copy, coef: 0.5, target: another
      ).to_record

      expect(cloned).to be_eql(another)
      expect(cloned.age).to eq 16.5
      expect(cloned.rating).to eq 1
      expect(cloned.name).to eq 'Jack'
    end
  end
end

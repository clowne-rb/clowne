describe Clowne::Adapters::Sequel::Associations::ManyToMany, :cleanup, adapter: :sequel do
  let(:source) { create('sequel:post', :with_tags, tags_num: 2) }
  let(:record) { Sequel::Post.new }
  let(:reflection) { Sequel::Post.association_reflections[:tags] }
  let(:scope) { {} }
  let(:declaration_params) { {} }
  let(:declaration) do
    Clowne::Declarations::IncludeAssociation.new(:tags, scope, **declaration_params)
  end
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, params) }

  describe '.call' do
    subject { resolver.call(record) }

    it 'clones all the tags withtout cloner' do
      expect(subject.tags.size).to eq 2
      expect(subject.tags.first).to be_a(Sequel::Tag)
      expect(subject.tags.first.to_hash).to eq(
        value: source.tags.first.value,
        created_at: nil,
        updated_at: nil
      )
      expect(subject.tags.second.to_hash).to eq(
        value: source.tags.second.value,
        created_at: nil,
        updated_at: nil
      )
    end

    context 'with scope' do
      let(:scope) { ->(params) { where(value: params[:with_tag]) if params[:with_tag] } }
      let(:params) { { with_tag: source.tags.second.value } }

      it 'clones scoped children' do
        expect(subject.tags.size).to eq 1
        expect(subject.tags.first.to_hash).to include(
          value: source.tags.second.value
        )
      end
    end

    context 'with custom cloner' do
      let(:tag_cloner) do
        Class.new(Clowne::Cloner) do
          finalize do |_source, record, params|
            record.value += params.fetch(:suffix, '-2')
          end

          trait :mark_as_clone do
            finalize do |_source, record|
              record.value += ' (Cloned)'
            end
          end
        end
      end

      let(:declaration_params) { { clone_with: tag_cloner } }

      it 'applies custom cloner' do
        expect(subject.tags.size).to eq 2
        expect(subject.tags.first.to_hash).to include(
          value: "#{source.tags.first.value}-2"
        )
      end

      context 'with params' do
        let(:params) { { suffix: '-new' } }

        it 'pass params to child cloner' do
          expect(subject.tags.size).to eq 2
          expect(subject.tags.first.to_hash).to include(
            value: "#{source.tags.first.value}-new"
          )
        end
      end

      context 'with traits' do
        let(:declaration_params) { { clone_with: tag_cloner, traits: :mark_as_clone } }

        it 'pass traits to child cloner' do
          expect(subject.tags.size).to eq 2
          expect(subject.tags.first.to_hash).to include(
            value: "#{source.tags.first.value}-2 (Cloned)"
          )
        end
      end
    end
  end
end

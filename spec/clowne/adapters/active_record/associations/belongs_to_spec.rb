describe Clowne::Adapters::ActiveRecord::Associations::BelongsTo, :cleanup, adapter: :active_record do
  let(:adapter) { Clowne::Adapters::ActiveRecord.new }
  let(:image) { create(:image) }
  let(:topic) { create(:topic, image: image) }
  let(:post) { create(:post, topic: topic) }
  let(:source) { post }
  let(:declaration_params) { {} }
  let(:record) { AR::Post.new }
  let(:reflection) { AR::Post.reflections['topic'] }
  let(:association) { :topic }
  let(:declaration) do
    Clowne::Declarations::IncludeAssociation.new(association, **declaration_params)
  end
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, adapter, params) }

  before(:all) do
    module AR
      class TopicCloner < Clowne::Cloner
        finalize do |source, record, params|
          record.created_at = source.created_at if params[:include_timestamps]
        end

        nullify :updated_at, :created_at

        include_association :image, params: true

        trait :mark_as_clone do
          finalize do |source, record|
            record.description = source.description + ' (Cloned)'
          end
        end
      end

      class ImageCloner < Clowne::Cloner
        finalize do |source, record, params|
          record.created_at = source.created_at if params[:include_timestamps]
        end

        nullify :updated_at, :created_at

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + ' (Cloned)'
          end
        end
      end
    end
  end

  after(:all) do
    AR.send(:remove_const, 'TopicCloner')
    AR.send(:remove_const, 'ImageCloner')
  end

  describe '.call' do
    subject { Clowne::Utils::Operation.wrap { resolver.call(record) }.to_record }

    it 'infers default cloner from model name' do
      expect(subject.topic).to be_new_record
      expect(subject.topic).to have_attributes(
        description: topic.description,
        image_id: nil,
        created_at: nil,
        updated_at: nil
      )
      expect(subject.topic.image).to be_new_record
      expect(subject.topic.image).to have_attributes(
        id: nil,
        post_id: nil,
        title: image.title,
        updated_at: nil,
        created_at: nil
      )
    end

    context 'with params' do
      let(:declaration_params) { { params: true } }
      let(:params) { { include_timestamps: true } }

      it 'pass params to child cloner' do
        expect(subject.topic).to be_new_record
        expect(subject.topic).to have_attributes(
          description: topic.description,
          image_id: nil,
          created_at: topic.created_at,
          updated_at: nil
        )
        expect(subject.topic.image).to be_new_record
        expect(subject.topic.image).to have_attributes(
          id: nil,
          post_id: nil,
          title: image.title,
          updated_at: nil,
          created_at: image.created_at
        )
      end
    end

    context 'with traits' do
      let(:declaration_params) { { traits: [:mark_as_clone] } }
      let(:params) { { include_timestamps: true } }

      it 'includes traits for self' do
        expect(subject.topic).to be_new_record
        expect(subject.topic).to have_attributes(
          description: "#{topic.description} (Cloned)",
          image_id: nil,
          created_at: nil,
          updated_at: nil
        )
        expect(subject.topic.image).to be_new_record
        expect(subject.topic.image).to have_attributes(
          id: nil,
          post_id: nil,
          title: image.title,
          updated_at: nil,
          created_at: nil
        )
      end
    end

    context 'with custom cloner' do
      let(:topic_cloner) do
        Class.new(Clowne::Cloner) do
          nullify :image_id

          finalize do |source, record, _params|
            record.description = "Copy of #{source.description}"
          end
        end
      end

      let(:declaration_params) { { clone_with: topic_cloner } }

      it 'applies custom cloner' do
        expect(subject.topic).to be_new_record
        expect(subject.topic).to have_attributes(
          description: "Copy of #{topic.description}"
        )
        expect(subject.topic.image).to be_nil
      end
    end
  end
end

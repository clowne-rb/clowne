describe Clowne::Adapters::Sequel::Associations::OneToOne, :cleanup, adapter: :sequel do
  let(:post) { create('sequel:post') }
  let!(:image) { create('sequel:image', :with_preview_image, post: post) }
  let(:source) { post }
  let(:declaration_params) { {} }
  let(:record) { Sequel::Post.new }
  let(:reflection) { Sequel::Post.association_reflections[:image] }
  let(:association) { :image }
  let(:declaration) do
    Clowne::Declarations::IncludeAssociation.new(association, **declaration_params)
  end
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, params) }

  before(:all) do
    module Sequel
      class ImageCloner < Clowne::Cloner
        finalize do |source, record, params|
          record.created_at = source.created_at if params[:include_timestamps]
        end

        nullify :updated_at, :created_at

        include_association :preview_image, params: true

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + ' (Cloned)'
          end
        end
      end

      class PreviewImageCloner < Clowne::Cloner
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
    Sequel.send(:remove_const, 'ImageCloner')
    Sequel.send(:remove_const, 'PreviewImageCloner')
  end

  describe '.call' do
    subject { Clowne::Adapters::Sequel::Operation.wrap { resolver.call(record) }.to_record }

    it 'infers default cloner from model name' do
      expect(subject.image).to be_new
      expect(subject.image).to be_a(Sequel::Image)
      expect(subject.image.to_hash).to eq(
        post_id: nil,
        title: image.title,
        created_at: nil,
        updated_at: nil
      )
      expect(subject.image.preview_image).to be_new
      expect(subject.image.preview_image.to_hash).to eq(
        some_stuff: image.preview_image.some_stuff,
        image_id: nil,
        created_at: nil,
        updated_at: nil
      )
    end

    context 'with params' do
      let(:declaration_params) { { params: true } }
      let(:params) { { include_timestamps: true } }

      it 'pass params to child cloner' do
        expect(subject.image).to be_new
        expect(subject.image).to have_attributes(
          post_id: nil,
          title: image.title
        )
        expect(subject.image.created_at).not_to be_nil
        expect(subject.image.preview_image).to be_new
        expect(subject.image.preview_image).to have_attributes(
          some_stuff: image.preview_image.some_stuff,
          image_id: nil
        )
        expect(subject.image.preview_image.created_at).not_to be_nil
      end
    end

    context 'with traits' do
      let(:declaration_params) { { traits: [:mark_as_clone] } }

      it 'includes traits for self' do
        expect(subject.image).to be_new
        expect(subject.image).to have_attributes(
          post_id: nil,
          title: "#{image.title} (Cloned)"
        )
        expect(subject.image.preview_image).to be_new
        expect(subject.image.preview_image).to have_attributes(
          some_stuff: image.preview_image.some_stuff,
          image_id: nil
        )
      end
    end

    context 'with custom cloner' do
      let(:image_cloner) do
        Class.new(Clowne::Cloner) do
          finalize do |source, record, _params|
            record.title = "Copy of #{source.title}"
          end
        end
      end

      let(:declaration_params) { { clone_with: image_cloner } }

      it 'applies custom cloner' do
        expect(subject.image).to be_new
        expect(subject.image).to have_attributes(
          post_id: nil,
          title: "Copy of #{image.title}"
        )
        expect(subject.image.preview_image).to be_nil
      end
    end
  end
end

describe Clowne::Adapters::ActiveRecord::Associations::HasOne, :cleanup, adapter: :active_record do
  let(:adapter) { Clowne::Adapters::ActiveRecord.new }
  let(:image) { create(:image, :with_preview_image) }
  let(:post) { create(:post, image: image) }
  let(:source) { post }
  let(:declaration_params) { {} }
  let(:record) { AR::Post.new }
  let(:reflection) { AR::Post.reflections["image"] }
  let(:association) { :image }
  let(:declaration) do
    Clowne::Declarations::IncludeAssociation.new(association, **declaration_params)
  end
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, adapter, params) }

  before(:all) do
    module AR
      class ImageCloner < Clowne::Cloner
        finalize do |source, record, params|
          record.created_at = source.created_at if params[:include_timestamps]
        end

        nullify :updated_at, :created_at

        include_association :preview_image, params: true

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + " (Cloned)"
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
            record.title = source.title + " (Cloned)"
          end
        end
      end
    end
  end

  after(:all) do
    AR.send(:remove_const, "ImageCloner")
    AR.send(:remove_const, "PreviewImageCloner")
  end

  describe ".call" do
    subject { Clowne::Utils::Operation.wrap { resolver.call(record) }.to_record }

    it "infers default cloner from model name" do
      expect(subject.image).to be_new_record
      expect(subject.image).to have_attributes(
        updated_at: nil,
        created_at: nil,
        post_id: nil,
        title: image.title
      )
      expect(subject.image.preview_image).to be_new_record
      expect(subject.image.preview_image).to have_attributes(
        updated_at: nil,
        created_at: nil,
        some_stuff: image.preview_image.some_stuff,
        image_id: nil
      )
    end

    context "with params" do
      let(:declaration_params) { {params: true} }
      let(:params) { {include_timestamps: true} }

      it "pass params to child cloner" do
        expect(subject.image).to be_new_record
        expect(subject.image).to have_attributes(
          updated_at: nil,
          created_at: image.created_at,
          post_id: nil,
          title: image.title
        )
        expect(subject.image.preview_image).to be_new_record
        expect(subject.image.preview_image).to have_attributes(
          updated_at: nil,
          created_at: image.preview_image.created_at,
          some_stuff: image.preview_image.some_stuff,
          image_id: nil
        )
      end
    end

    context "with traits" do
      let(:declaration_params) { {traits: [:mark_as_clone]} }

      it "includes traits for self" do
        expect(subject.image).to be_new_record
        expect(subject.image).to have_attributes(
          updated_at: nil,
          created_at: nil,
          post_id: nil,
          title: "#{image.title} (Cloned)"
        )
        expect(subject.image.preview_image).to be_new_record
        expect(subject.image.preview_image).to have_attributes(
          updated_at: nil,
          created_at: nil,
          some_stuff: image.preview_image.some_stuff,
          image_id: nil
        )
      end
    end

    context "with custom cloner" do
      let(:image_cloner) do
        Class.new(Clowne::Cloner) do
          finalize do |source, record, _params|
            record.title = "Copy of #{source.title}"
          end
        end
      end

      let(:declaration_params) { {clone_with: image_cloner} }

      it "applies custom cloner" do
        expect(subject.image).to be_new_record
        expect(subject.image).to have_attributes(
          post_id: nil,
          title: "Copy of #{image.title}"
        )
        expect(subject.image.preview_image).to be_nil
      end
    end
  end
end

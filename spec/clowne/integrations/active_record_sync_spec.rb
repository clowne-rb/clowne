describe 'AR Sync adapter', :cleanup, adapter: :active_record, transactional: :active_record do
  before(:all) do
    module AR
      class ImgCloner < Clowne::Cloner
        # include_association :preview_image, params: :preview_image

        nullify :title
      end

      class PostCloner < Clowne::Cloner
        include_association :image, clone_with: 'AR::ImgCloner',
                                    params: true
        # include_association :tags, ->(params) { where(value: params[:tags]) if params[:tags] }

        finalize do |source, record|
          record.title = source.title + ' Super!'
        end
      end

      class PostSyncer < PostCloner
        adapter :active_record_sync

        finalize do |source, record, **|
          record.assign_attributes(source.attributes.except('id'))
        end
      end

      # class PreviewImageCloner < Clowne::Cloner
      #   finalize do |_source, record, suffix:|
      #     record.some_stuff = record.some_stuff + suffix
      #   end
      # end
    end
  end

  after(:all) do
    %w[ImgCloner PostCloner].each do |cloner|
      AR.send(:remove_const, cloner)
    end
  end

  let!(:image) { create(:image, title: 'Manager') }
  let!(:post) { create(:post, title: 'TeamCity', image: image) }
  # let!(:preview_image) do
  #   create(:preview_image, some_stuff: 'This is preview about my life', image: image)
  # end
  # let(:topic) { post.topic }

  # let!(:tags) do
  #   %w[CI CD JVM].map { |value| create(:tag, value: value) }.tap do |items|
  #     post.tags = items
  #   end
  # end

  let(:params) do
    {
      tags: %w[CI CD],
      post_contents: 'THIS IS CLONE! (☉_☉)',
      preview_image: { suffix: ' - 2' }
    }
  end

  let(:operation) do
    AR::PostCloner.call(post, **params).tap(&:persist!)
  end

  it 'sync cloned record' do
    clone = operation.to_record

    post.update_attributes!(title: 'Updated Title', contents: 'Updated Contents')
    clone.image.update_attributes!(title: 'This is post image')

    etalon_clone = AR::Post.find(clone.id)
    etalon_image = AR::Image.find(clone.image.id)

    ActiveRecord::Base.logger = Logger.new(STDOUT)
    result = AR::PostSyncer.call(post, **params.merge(mapper: operation.mapper))

    expect do
      result.persist
    end.to change { etalon_clone.reload.title }.to('Updated Title')
      .and change { etalon_clone.reload.contents }.to('Updated Contents')
      .and change { etalon_image.reload.title }.to(nil)
  end
end

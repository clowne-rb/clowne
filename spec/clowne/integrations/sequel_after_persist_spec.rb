describe 'Sequel Post Processing', :cleanup, adapter: :sequel, transactional: :sequel do
  before(:all) do
    module Sequel
      class TopicCloner < Clowne::Cloner
        include_association :posts

        after_persist do |origin, clone, mapper:|
          cloned_image = mapper.clone_of(origin.image)
          binding.pry
          clone.update(image_id: cloned_image.id)
        end
      end

      class PostCloner < Clowne::Cloner
        include_association :image, clone_with: 'Sequel::ImgCloner',
                                    traits: %i[with_preview_image]
      end

      class ImgCloner < Clowne::Cloner
        trait :with_preview_image do
          include_association :preview_image
        end
      end
    end
  end

  after(:all) do
    %w[TopicCloner PostCloner ImgCloner].each do |cloner|
      Sequel.send(:remove_const, cloner)
    end
  end

  let!(:topic) { create('sequel:topic') }
  let!(:posts) { create_list('sequel:post', 3, topic: topic) }
  let!(:images) { posts.collect { |post| create('sequel:image', post: post) } }
  let(:topic_image) { images.sample }

  before do
    images.each { |image| create('sequel:preview_image', image: image) }
    topic.update(image_id: topic_image.id)
  end

  describe 'The main idea of "after persist" feature is a possibility
      to fix broken associations when you clone complex record.
      In our case, topic has a link to one of the posts images
      and we need to update the cloned topic with the cloned image' do

    subject(:operation) { Sequel::TopicCloner.call(topic) }

    # rubocop:disable MultilineMethodCallIndentation
    it 'clone and use cloned image' do
      expect do
        operation.persist
      end.to change(Sequel::Topic, :count).by(+1)
        .and change(Sequel::Post, :count).by(+3)
        .and change(Sequel::Image, :count).by(+3)

      cloned = operation.to_record
      expect(cloned.reload.image_id).not_to eq(topic_image.id)

      expect(cloned.image.post.topic).to eq(cloned)
    end
    # rubocop:enable MultilineMethodCallIndentation
  end
end

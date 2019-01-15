describe 'Post Processing', :cleanup, adapter: :active_record, transactional: :active_record do
  before(:all) do
    module AR
      class TopicCloner < Clowne::Cloner
        include_association :posts

        after_persist do |origin, clone, mapper:|
          cloned_image = mapper.clone_of(origin.image)
          clone.update_attributes(image_id: cloned_image.id)
        end
      end

      class PostCloner < Clowne::Cloner
        include_association :image, clone_with: 'AR::ImgCloner',
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
      AR.send(:remove_const, cloner)
    end
  end

  let!(:topic) { create(:topic) }
  let!(:posts) { create_list(:post, 3, topic: topic) }
  let!(:images) { posts.map(&:image) }
  let(:topic_image) { images.sample }

  before do
    images.each { |image| create(:preview_image, image: image) }
    topic.update_attributes(image_id: topic_image.id)
  end

  describe 'The main idea of "post-processing" feature is a possibility
      to fix broken associations when you clone complex record.
      In our case, topic has a link to one of the posts images
      and we need to update the cloned topic with the cloned image' do

    subject(:operation) { AR::TopicCloner.call(topic) }

    # rubocop:disable MultilineMethodCallIndentation
    it 'clone and use cloned image' do
      expect do
        operation.save
      end.to change(AR::Topic, :count).by(+1)
        .and change(AR::Post, :count).by(+3)
        .and change(AR::Image, :count).by(+3)

      cloned = operation.clone
      expect { operation.run_after_persist! }.to change {
        cloned.reload.image_id
      }.from(topic_image.id)

      expect(cloned.image.post.topic).to eq(cloned)
    end
    # rubocop:enable MultilineMethodCallIndentation
  end

  describe 'pass mappping' do
    let(:another_image) { create(:image) }
    let(:mapper) do
      Class.new(Clowne::Utils::CloneMapper).new.tap do |stub_mapper|
        expect(stub_mapper).to receive(:clone_of).and_return(another_image)
      end
    end

    subject(:operation) { AR::TopicCloner.call(topic, mapper: mapper) }

    it 'uses another_image' do
      operation.save
      cloned = operation.clone
      expect { operation.run_after_persist! }.to change {
        cloned.reload.image_id
      }.to(another_image.id)
    end
  end
end

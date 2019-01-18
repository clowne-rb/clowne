describe 'Sequel Post Processing', :cleanup, adapter: :sequel, transactional: :sequel do
  before(:all) do
    module Sequel
      class TopicCloner < Clowne::Cloner
        include_association :posts

        after_persist do |origin, clone, mapper:|
          cloned_image = mapper.clone_of(origin.image)
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

  describe 'clone_of does not support for default mapper' do
    subject(:operation) { Sequel::TopicCloner.call(topic) }

    it 'clone and use cloned image' do
      expect { operation.persist }.to raise_exception(
        Clowne::Adapters::Sequel::Specifications::CloneOfDoesNotSupport::CloneOfDoesNotSupportException
      )
    end
  end

  describe 'pass mappping' do
    let(:another_image) { create(:image) }
    let(:mapper) do
      Class.new(Clowne::Utils::CloneMapper).new.tap do |stub_mapper|
        expect(stub_mapper).to receive(:clone_of).and_return(another_image)
      end
    end

    subject(:operation) { Sequel::TopicCloner.call(topic, mapper: mapper) }

    it 'uses another_image' do
      cloned = operation.to_record
      cloned.save
      expect { operation.run_after_persist }.to change {
        cloned.reload.image_id
      }.to(another_image.id)
    end
  end
end

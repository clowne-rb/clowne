describe "Sequel Post Processing", :cleanup, adapter: :sequel, transactional: :sequel do
  before(:all) do
    module Sequel
      class TopicCloner < Clowne::Cloner
        include_association :posts
      end

      class PostCloner < Clowne::Cloner
        include_association :image, clone_with: "Sequel::ImgCloner"
      end

      class ImgCloner < Clowne::Cloner
        after_persist do |_origin, _clone, mapper:|
          # raise even empty block
        end
      end
    end
  end

  after(:all) do
    %w[TopicCloner PostCloner ImgCloner].each do |cloner|
      Sequel.send(:remove_const, cloner)
    end
  end

  let!(:topic) { create("sequel:topic") }
  let!(:post) { create("sequel:post", topic: topic) }
  let!(:image) { create("sequel:image", post: post) }

  describe "after_persist does not support for default mapper" do
    subject(:operation) { Sequel::TopicCloner.call(topic) }

    it "clone and use after_persis" do
      expect { operation }.to raise_exception(
        Clowne::Adapters::Sequel::Specifications::AfterPersistDoesNotSupportException
      )
    end
  end
end

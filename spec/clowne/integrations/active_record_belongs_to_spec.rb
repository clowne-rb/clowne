# frozen_string_literal: true

describe "AR belongs to loop", :cleanup, adapter: :active_record, transactional: :active_record do
  before(:all) do
    module AR
      class PostCloner < Clowne::Cloner
        include_association :topic
      end

      class TopicCloner < Clowne::Cloner
        include_association :image
      end

      class ImageCloner < Clowne::Cloner
        include_association :post
      end
    end
  end

  after(:all) do
    %w[PostCloner TopicCloner ImageCloner].each do |cloner|
      AR.send(:remove_const, cloner)
    end
  end

  let!(:post) { create(:post, title: "TeamCity", topic: topic, image: image) }
  let(:image) { create(:image, title: "Manager") }
  let(:topic) { create(:topic, image: image) }

  # TruffleRuby results in a warning an a stack overflow exceptions out of the interpreter
  it "clone loop", skip: defined?(TruffleRuby) do
    expect(AR::Topic.count).to eq(1)
    expect(AR::Post.count).to eq(1)
    expect(AR::Image.count).to eq(1)

    expect { AR::PostCloner.call(post).to_record }.to(raise_error do |error|
      expect(%w[SystemStackError Java::JavaLang::StackOverflowError]).to include(error.class.name)
    end)
  end
end

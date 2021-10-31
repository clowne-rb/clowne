describe "Adapter Lifecycle", :cleanup, adapter: :base, transactional: :active_record do
  class DummyAdapter < Clowne::Adapters::ActiveRecord
    class << self
      def dup_record(record)
        super.tap do |clone|
          clone.title = "I'm a clone of #{record.class.name}-#{record.id}"
        end
      end
    end
  end

  before(:all) do
    module AR
      class TopicCloner < Clowne::Cloner
        include_association :posts
      end

      class PostCloner < Clowne::Cloner; end
    end
  end

  after(:all) do
    %w[TopicCloner PostCloner].each do |cloner|
      AR.send(:remove_const, cloner)
    end
  end

  shared_examples "pass adapter" do
    it "clones topic" do
      expect do
        operation.persist
      end.to change(AR::Topic, :count).by(+1)
        .and change(AR::Post, :count).by(+3)
    end
    # rubocop:enable Layout/MultilineMethodCallIndentation

    it "uses DummyAdapter in all levels" do
      operation.persist
      clone = operation.to_record
      expect(clone.title).to eq("I'm a clone of AR::Topic-#{topic.id}")
      expect(clone.posts.first.title).to eq("I'm a clone of AR::Post-#{topic.posts.first.id}")
    end
  end

  let!(:topic) { create(:topic) }
  let!(:posts) { create_list(:post, 3, topic: topic) }

  describe "Pass root adapter over cloners" do
    it_behaves_like "pass adapter" do
      subject(:operation) { AR::TopicCloner.call(topic) }

      before do
        AR::TopicCloner.class_eval do
          adapter DummyAdapter.new
        end
      end
    end
  end

  describe "Pass adapter over cloners as option" do
    it_behaves_like "pass adapter" do
      subject(:operation) { AR::TopicCloner.call(topic, adapter: DummyAdapter.new) }
    end
  end
end

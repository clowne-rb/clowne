# frozen_string_literal: true

describe "Pre processing", :cleanup, adapter: :active_record, transactional: :active_record do
  before(:all) do
    module AR
      class TopicCloner < Clowne::Cloner
        include_association :posts

        after_clone do |_origin, clone, **|
          raise Clowne::UnprocessableSourceError, "Topic has no posts!" if clone.posts.empty?
        end
      end
    end
  end

  after(:all) do
    AR.send(:remove_const, "TopicCloner")
  end

  let!(:topic) { create(:topic) }

  describe 'The main idea of "after clone" feature is a possibility
      to make some additional work or checks on cloned record before
      persisting it.' do
    subject(:operation) { AR::TopicCloner.call(topic) }

    it "raises error" do
      expect do
        operation.persist
      end.to raise_error(Clowne::UnprocessableSourceError)
    end
  end
end

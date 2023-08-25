# frozen_string_literal: true

describe "Sequel Post Processing", :cleanup, adapter: :sequel, transactional: :sequel do
  before(:all) do
    module Sequel
      class TopicCloner < Clowne::Cloner
        include_association :posts

        after_clone do |_origin, clone, **|
          raise Clowne::UnprocessableSourceError, "Topic has no posts!" if clone.posts.empty?
        end
      end
    end
  end

  after(:all) do
    Sequel.send(:remove_const, "TopicCloner")
  end

  let!(:topic) { create("sequel:topic") }

  describe 'The main idea of "after clone" feature is a possibility
      to make some additional work or checks on cloned record before
      persisting it.' do
    subject(:operation) { Sequel::TopicCloner.call(topic) }

    it "raises error" do
      expect do
        operation.to_record
      end.to raise_error(Clowne::UnprocessableSourceError)
    end
  end
end

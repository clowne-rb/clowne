RSpec.describe Clowne::ActiveRecordAdapter::CloneAssociation do
  describe 'has one association' do
    let(:topic) { Topic.create(title: 'Some post', description: 'Some description' ) }
    let(:source) { Post.create(topic: topic) }
    let(:record) { Post.new }

    subject { described_class.call(source, record, declaration) }

    context 'when simple has one association' do
      let(:declaration) { double(association: :topic) }

      it "clone source's post" do
        expect(subject.topic).to be_a(Topic)
        expect(subject.topic.title).to eq('Some post')
        expect(subject.topic.description).to eq('Some description')
      end
    end
  end
end

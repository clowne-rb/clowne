describe Clowne::Adapters::ActiveRecord do
  let(:source) { create(:post) }

  let(:operation) do
    Clowne::Utils::Operation.wrap { described_class.new.dup_source(source) }
  end

  describe 'duplicate' do
    subject(:clone) { operation.to_record }

    it "get source's dup" do
      expect(subject).to be_a(::AR::Post)
      expect(subject).to be_new_record
      expect(subject.id).to be_nil
      expect(subject.created_at).to be_nil
      expect(subject.updated_at).to be_nil
    end

    describe 'mapper' do
      subject(:mapper) { operation.mapper }

      it 'saves mapping' do
        expect(mapper.clone_of(source)).to eq(clone)
      end
    end
  end
end

describe Clowne::Adapters::Base do
  subject { described_class.new }

  describe '.clone_record' do
    it 'clones simple objects' do
      source = { a: 1 }
      cloned = subject.clone_record(source)
      cloned.delete(:a)
      expect(source[:a]).to eq 1
    end

    it 'handles non-dupable object', :aggregate_failures do
      expect(subject.clone_record(nil)).to be_nil
      expect(subject.clone_record(42)).to eq 42
    end
  end

  xdescribe '.resolve_declaration'
end

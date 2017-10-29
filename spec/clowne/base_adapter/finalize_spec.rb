RSpec.describe Clowne::BaseAdapter::Finalize do
  let(:object) { described_class.new(source, record, declaration) }

  let(:declaration) { Clowne::Declarations::Finalize.new(block) }

  describe '.call' do
    let(:source) { User.new(email: 'admin@example.com') }
    let(:block) do
      Proc.new { |source, record|
        record.email = source.email.gsub('example.com', 'gmail.com')
      }
    end

    it 'execute finalize block' do
      record = User.new
      result = described_class.call(source, record, declaration)
      expect(result).to be_a(User)
      expect(result.email).to eq('admin@gmail.com')
    end
  end
end

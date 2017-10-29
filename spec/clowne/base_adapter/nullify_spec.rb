RSpec.describe Clowne::BaseAdapter::Nullify do
  let(:object) { described_class.new(source, record, declaration) }

  let(:declaration) { Clowne::Declarations::Nullify.new(attrs) }

  describe '.call' do
    let(:record) { User.new(name: 'Admin', email: 'admin@example.com') }
    let(:attrs) { [:email] }

    it 'execute nullify' do
      result = described_class.call(double, record, declaration)
      expect(result).to be_a(User)
      expect(result.name).to eq('Admin')
      expect(result.email).to be_nil
    end
  end
end

RSpec.describe Clowne::BaseAdapter::Nullify do
  let(:declaration) { Clowne::Declarations::Nullify.new(attrs) }

  describe '.call' do
    let(:record) { User.new(name: 'Admin', email: 'admin@example.com') }
    let(:attrs) { [:email] }

    it 'execute nullify' do
      result = described_class.call(double, record, declaration, double)
      expect(result).to be_a(User)
      expect(result.name).to eq('Admin')
      expect(result.email).to be_nil
    end
  end
end

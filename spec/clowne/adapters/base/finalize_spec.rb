describe Clowne::Adapters::Base::Finalize do
  let(:declaration) { Clowne::Declarations::Finalize.new(&block) }

  describe '.call' do
    let(:source) { User.new(email: 'admin@example.com') }
    let(:block) do
      proc do |source, record|
        record.email = source.email.gsub('example.com', 'gmail.com')
      end
    end

    it 'execute finalize block' do
      record = User.new
      result = described_class.call(source, record, declaration, params: {})
      expect(result).to be_a(User)
      expect(result.email).to eq('admin@gmail.com')
    end

    context 'with params' do
      let(:block) do
        proc do |_source, record, params|
          record.email = params[:email]
        end
      end

      it 'execute finalize block with params' do
        record = User.new
        result = described_class.call(source, record, declaration, params: { email: 'admin@yahoo.com' })
        expect(result).to be_a(User)
        expect(result.email).to eq('admin@yahoo.com')
      end
    end
  end
end

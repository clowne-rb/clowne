describe Clowne::Adapters::Resolvers::PostProcessing do
  let(:declaration) { Clowne::Declarations::PostProcessing.new(&block) }

  describe '.call' do
    let(:source) { AR::User.create(email: 'admin@example.com') }
    let(:params) { {} }
    let(:block) do
      proc do |source, record, mapper:|
        record.update_attributes(email: "admin#{ record.id }@#{ mapper.clone_of(source) }")
      end
    end

    subject(:result) do
      record = AR::User.new
      operation = Clowne::Operation.wrap { described_class.call(source, record, declaration, params: params) }
      operation.add_mapping(source, 'example.com')
      operation.save_with_magic
      operation.clone
    end

    it 'execute post_processing block' do
      expect(result).to be_a(AR::User)
      expect(result.email).to eq("admin#{ result.id }@example.com")
    end

    context 'with params' do
      let(:params) { { email: 'admin@yahoo.com' } }
      let(:block) do
        proc do |_source, record, params|
          record.email = params[:email]
        end
      end

      it 'execute finalize block with params' do
        expect(result).to be_a(AR::User)
        expect(result.email).to eq('admin@yahoo.com')
      end
    end
  end
end

describe Clowne::Resolvers::AfterPersist do
  let(:declaration) { Clowne::Declarations::AfterPersist.new(&block) }

  describe '.call' do
    let(:source) { AR::User.create(email: 'admin@example.com') }
    let(:params) { {} }
    let(:block) do
      proc do |source, record, mapper:|
        record.update_attributes(email: "admin#{record.id}@#{mapper.clone_of(source)}")
      end
    end

    subject(:result) do
      record = AR::User.new
      operation = Clowne::Utils::Operation.wrap do
        described_class.call(source, record, declaration, params: params)
      end
      operation.add_mapping(source, 'example.com')
      operation.save
      operation.run_after_persist!
      operation.clone
    end

    it 'execute after_persist block' do
      expect(result).to be_a(AR::User)
      expect(result.email).to eq("admin#{result.id}@example.com")
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

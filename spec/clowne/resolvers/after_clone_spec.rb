describe Clowne::Resolvers::AfterClone do
  let(:declaration) { Clowne::Declarations::AfterClone.new(&block) }

  describe ".call" do
    let(:source) { AR::User.create(email: "admin@example.com") }
    let(:params) { {} }
    let(:block) do
      proc do |_source, record|
        record.email = "admin-cloned@example.com"
      end
    end

    subject(:result) do
      record = AR::User.new
      operation = Clowne::Utils::Operation.wrap do
        described_class.call(source, record, declaration, params: params)
      end
      operation.persist
      operation.to_record
    end

    it "execute after_clone block" do
      expect(result).to be_a(AR::User)
      expect(result.email).to eq("admin-cloned@example.com")
    end

    context "with params" do
      let(:params) { {email: "admin@yahoo.com"} }
      let(:block) do
        proc do |_source, record, params|
          record.email = params[:email]
        end
      end

      it "execute after_clone block with params" do
        expect(result).to be_a(AR::User)
        expect(result.email).to eq("admin@yahoo.com")
      end
    end
  end
end

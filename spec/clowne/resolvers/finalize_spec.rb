describe Clowne::Resolvers::Finalize do
  let(:declaration) { Clowne::Declarations::Finalize.new(&block) }

  describe ".call" do
    let(:source) { AR::User.new(email: "admin@example.com") }
    let(:params) { {} }
    let(:block) do
      proc do |source, record|
        record.email = source.email.gsub("example.com", "gmail.com")
      end
    end

    subject(:result) do
      record = AR::User.new
      described_class.call(source, record, declaration, params: params)
    end

    it "execute finalize block" do
      expect(result).to be_a(AR::User)
      expect(result.email).to eq("admin@gmail.com")
    end

    context "with params" do
      let(:params) { {email: "admin@yahoo.com"} }
      let(:block) do
        proc do |_source, record, params|
          record.email = params[:email]
        end
      end

      it "execute finalize block with params" do
        expect(result).to be_a(AR::User)
        expect(result.email).to eq("admin@yahoo.com")
      end
    end
  end
end

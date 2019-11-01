describe Clowne::Resolvers::Nullify do
  let(:declaration) { Clowne::Declarations::Nullify.new(*args) }

  describe ".call" do
    let(:record) { AR::User.new(name: "Admin", email: "admin@example.com") }
    let(:args) { [:email] }

    it "nullifies fields" do
      result = described_class.call(double, record, declaration)
      expect(result).to be_a(AR::User)
      expect(result.name).to eq("Admin")
      expect(result.email).to be_nil
    end

    context "with multiple attributes" do
      let(:args) { [:name, :email] }

      it "nullifies fields" do
        result = described_class.call(double, record, declaration)
        expect(result).to be_a(AR::User)
        expect(result.name).to be_nil
        expect(result.email).to be_nil
      end
    end
  end
end

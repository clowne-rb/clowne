# frozen_string_literal: true

describe Clowne::Declarations::InitAs do
  describe ".new" do
    context "with block" do
      it "works" do
        declaration = described_class.new { "some block" }
        expect(declaration.block).to be_instance_of(Proc)
      end
    end

    context "when block has not passed" do
      it "raise ArgumentError" do
        expect { described_class.new }.to raise_error(
          ArgumentError,
          "Block is required for init_as"
        )
      end
    end
  end
end

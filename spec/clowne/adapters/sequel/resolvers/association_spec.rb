describe Clowne::Adapters::Sequel::Resolvers::Association do
  let(:adapter) { Clowne::Adapters::Sequel.new }
  let(:params) { double }
  let(:record) { double }
  let(:association) {}
  let(:source) { build_stubbed("sequel:post") }
  let(:declaration) { Clowne::Declarations::IncludeAssociation.new(association) }

  subject { described_class.call(source, record, declaration, adapter: adapter, params: params) }

  context "with one_to_many" do
    let(:association) { :posts }
    let(:source) { build_stubbed("sequel:user") }

    it "uses OneToMany resolver" do
      expect(Clowne::Adapters::Sequel::Associations::OneToMany).to receive(:new).with(
        Sequel::User.association_reflections[:posts], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "with one_to_one" do
    let(:association) { :image }

    it "uses OneToOne resolver" do
      expect(Clowne::Adapters::Sequel::Associations::OneToOne).to receive(:new).with(
        Sequel::Post.association_reflections[:image], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "with many_to_one" do
    let(:association) { :topic }

    it "uses Noop resolver" do
      expect(Clowne::Adapters::Sequel::Associations::Noop).to receive(:new).with(
        Sequel::Post.association_reflections[:topic], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "with many_to_many" do
    let(:association) { :tags }

    it "uses ManyToMany resolver" do
      expect(Clowne::Adapters::Sequel::Associations::ManyToMany).to receive(:new).with(
        Sequel::Post.association_reflections[:tags], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "not clonable association" do
    let(:association) { :owner }

    it "does not call any resolver" do
      expect(Clowne::Adapters::Sequel::Associations::Noop).not_to receive(:new) do
        double.tap do |resolver|
          expect(resolver).to receive(:call)
        end
      end

      subject
    end
  end
end

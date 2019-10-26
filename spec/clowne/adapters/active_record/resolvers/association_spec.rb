describe Clowne::Adapters::ActiveRecord::Resolvers::Association do
  let(:params) { double }
  let(:record) { double }
  let(:adapter) { double }
  let(:source) { build_stubbed(:post) }
  let(:declaration) { Clowne::Declarations::IncludeAssociation.new(association) }

  subject { described_class.call(source, record, declaration, adapter: adapter, params: params) }

  context "with has_many" do
    let(:association) { :posts }
    let(:source) { build_stubbed(:user) }

    it "uses HasMany resolver" do
      expect(Clowne::Adapters::ActiveRecord::Associations::HasMany).to receive(:new).with(
        AR::User.reflections["posts"], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "with has_many through" do
    let(:association) { :images }
    let(:source) { build_stubbed(:user) }

    it "uses Noop resolver" do
      expect(Clowne::Adapters::ActiveRecord::Associations::Noop).to receive(:new).with(
        AR::User.reflections["images"], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "with has_one" do
    let(:association) { :image }

    it "uses HasOne resolver" do
      expect(Clowne::Adapters::ActiveRecord::Associations::HasOne).to receive(:new).with(
        AR::Post.reflections["image"], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "with has_one through" do
    let(:association) { :preview_image }

    it "uses Noop resolver" do
      expect(Clowne::Adapters::ActiveRecord::Associations::Noop).to receive(:new).with(
        AR::Post.reflections["preview_image"], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "with belongs_to" do
    let(:association) { :topic }

    it "uses BelongsTo resolver" do
      expect(Clowne::Adapters::ActiveRecord::Associations::BelongsTo).to receive(:new).with(
        AR::Post.reflections["topic"], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end

  context "with HABTM" do
    let(:association) { :tags }

    it "uses HABTM resolver" do
      expect(Clowne::Adapters::ActiveRecord::Associations::HABTM).to receive(:new).with(
        AR::Post.reflections["tags"], source, declaration, adapter, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end
end

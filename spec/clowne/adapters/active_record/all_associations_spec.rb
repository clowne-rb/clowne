describe Clowne::Adapters::ActiveRecord::AllAssociations do
  let(:params) { double }
  let(:record) { double }
  let(:source) { build_stubbed(:post) }
  let(:excludes) { [] }
  let(:declaration) do
    Clowne::Declarations::IncludeAll.new.tap do |decl|
      excludes.each { |name| decl.except!(name) }
    end
  end

  subject { described_class.call(source, record, declaration, params: params) }

  it 'includes all associations (except belongs_to)' do
    expect(Clowne::Adapters::ActiveRecord::Associations::HasOne).to receive(:new).with(
      AR::Post.reflections['account'], source, anything, params
    ) do
      double.tap do |resolver|
        expect(resolver).to receive(:call).with(record)
      end
    end

    expect(Clowne::Adapters::ActiveRecord::Associations::Noop).to receive(:new).with(
      AR::Post.reflections['history'], source, anything, params
    ) do
      double.tap do |resolver|
        expect(resolver).to receive(:call).with(record)
      end
    end

    expect(Clowne::Adapters::ActiveRecord::Associations::HABTM).to receive(:new).with(
      AR::Post.reflections['tags'], source, declaration, params
    ) do
      double.tap do |resolver|
        expect(resolver).to receive(:call).with(record)
      end
    end

    subject
  end

  context 'with excludes' do
    let(:excludes) { [:account, :history] }

    it 'includes all associations (except belongs_to and exlicitly excluded)' do
      expect(Clowne::Adapters::ActiveRecord::Associations::HasOne).not_to receive(:new)
      expect(Clowne::Adapters::ActiveRecord::Associations::Noop).not_to receive(:new)

      expect(Clowne::Adapters::ActiveRecord::Associations::HABTM).to receive(:new).with(
        AR::Post.reflections['tags'], source, declaration, params
      ) do
        double.tap do |resolver|
          expect(resolver).to receive(:call).with(record)
        end
      end

      subject
    end
  end
end

describe Clowne::Declarations::IncludeAssociation do
  describe '#compile' do
    describe 'clone_with' do
      let(:settings) { { adapter: adapter } }
      let(:options) { {} }
      let(:adapter) { FakeAdapter }
      let(:association_name) { :animals }

      subject do
        declaration = described_class.new(association_name, nil, options)
        plan = declaration.compile(Clowne::Plan.new, settings)
        plan.declarations.first.custom_cloner
      end

      context 'when customer cloner not exist' do
        it { is_expected.to be_nil }
      end

      context 'when customer cloner exist' do
        before { class AnimalCloner < Clowne::Cloner; end }

        it { is_expected.to be_nil }

        context 'and adapter is ActiveRecord' do
          let(:adapter) { Clowne::ActiveRecord::Adapter }

          it { is_expected.to eq(AnimalCloner) }
        end

        context 'but defined clone_with option' do
          let(:cloner) { Class.new(Clowne::Cloner) }
          let(:options) { { clone_with: cloner } }

          it { is_expected.to eq(cloner) }
        end
      end

      context 'when exist class with name like cloner' do
        let(:adapter) { Clowne::ActiveRecord::Adapter }
        let(:association_name) { :admins }

        before { class AdminCloner; end }

        it { is_expected.to be_nil }
      end
    end
  end
end

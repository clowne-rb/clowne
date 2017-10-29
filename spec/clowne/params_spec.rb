RSpec.describe Clowne::Params do
  describe '[]' do
    let(:params) { { foo: 1 } }
    let(:strategy) do
      Class.new do
        def self.execute(key)
          :your_key_not_found
        end
      end
    end

    subject { described_class.new(params, strategy)[key] }

    context 'when key is defined' do
      let(:key) { :foo }

      it { is_expected.to eq(1) }
    end

    context 'when key is not defined' do
      let(:key) { :bar }

      it { is_expected.to eq(:your_key_not_found) }
    end
  end
end

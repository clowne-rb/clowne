describe Clowne::Utils::Params do
  describe 'build proxy' do
    let(:params) do
      {
        profile: { data: { name: 'Robin' } },
        rating: 10
      }
    end
    let(:permitted_params) { subject.permit(params: params) }

    subject { described_class.proxy(value) }

    context 'when value is true' do
      let(:value) { true }

      it { is_expected.to be_a(Clowne::Utils::Params::PassProxy) }

      it 'return all params' do
        expect(permitted_params).to eq(params)
      end
    end

    context 'when value is false' do
      let(:value) { false }

      it { is_expected.to be_a(Clowne::Utils::Params::NullProxy) }

      it 'return empty hash' do
        expect(permitted_params).to eq({})
      end
    end

    context 'when value is false' do
      let(:value) { nil }

      it { is_expected.to be_a(Clowne::Utils::Params::NullProxy) }

      it 'return empty hash' do
        expect(permitted_params).to eq({})
      end
    end

    context 'when value is a block' do
      let(:parent) { double }
      let(:permitted_params) { subject.permit(params: params, parent: parent) }

      context 'with 1 args' do
        let(:value) { ->(p) { p[:profile][:data] } }

        it { is_expected.to be_a(Clowne::Utils::Params::BlockProxy) }

        it 'return nested hash' do
          expect(permitted_params).to eq(name: 'Robin')
        end
      end

      context 'with 2 args' do
        let(:value) { ->(p, parent) { p[:profile][:data].merge(parent: parent) } }

        it { is_expected.to be_a(Clowne::Utils::Params::BlockProxy) }

        it 'return nested hash with record' do
          expect(permitted_params).to eq(name: 'Robin', parent: parent)
        end
      end
    end

    context 'when value is a key' do
      let(:value) { :profile }

      it { is_expected.to be_a(Clowne::Utils::Params::KeyProxy) }

      it 'return nested hash' do
        expect(permitted_params).to eq(data: { name: 'Robin' })
      end
    end

    context 'when value is a key but nested values is not a Hash' do
      let(:value) { :rating }

      it { is_expected.to be_a(Clowne::Utils::Params::KeyProxy) }

      it 'raise KeyError' do
        expect { permitted_params }.to raise_error(KeyError, "value by key 'rating' must be a Hash")
      end
    end

    context 'when value is undefined' do
      let(:value) { :blah }

      it 'raise KeyError' do
        expect { permitted_params }.to raise_error(KeyError, 'key not found: :blah')
      end
    end
  end
end

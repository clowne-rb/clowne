describe Clowne::Params do
  describe 'build filter' do
    let(:params) do
      {
        profile: { data: { name: 'Robin' } }
      }
    end
    let(:permitted_params) { subject.permit(params) }

    subject { described_class.filter(options) }

    context 'when options is true' do
      let(:options) { true }

      it { is_expected.to be_a(Clowne::Params::AllowFilter) }

      it 'return all params' do
        expect(permitted_params).to eq(params)
      end
    end

    context 'when options is false' do
      let(:options) { false }

      it { is_expected.to be_a(Clowne::Params::DenyFilter) }

      it 'return empty hash' do
        expect(permitted_params).to eq({})
      end
    end

    context 'when options is false' do
      let(:options) { nil }

      it { is_expected.to be_a(Clowne::Params::DenyFilter) }

      it 'return empty hash' do
        expect(permitted_params).to eq({})
      end
    end

    context 'when options is a Proc' do
      let(:options) { proc { |p| p[:profile][:data] } }

      it { is_expected.to be_a(Clowne::Params::ByBlockFilter) }

      it 'return empty hash' do
        expect(permitted_params).to eq(name: 'Robin')
      end
    end

    context 'when options is a Symbol' do
      let(:options) { :profile }

      it { is_expected.to be_a(Clowne::Params::ByKeyFilter) }

      it 'return empty hash' do
        expect(permitted_params).to eq(data: { name: 'Robin' })
      end
    end

    context 'when options is undefined' do
      let(:options) { 1 }

      it { is_expected.to be_a(Clowne::Params::ByKeyFilter) }

      it 'raise exception' do
        expect{ permitted_params }.to raise_error(KeyError)
      end
    end
  end
end

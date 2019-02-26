describe Clowne::Adapters::Base::Association do
  describe '.clone_one' do
    let(:adapter) { double }
    let(:reflection) { double }
    let(:source) { double }
    let(:child) { double }
    let(:child_cloner) { double }
    let(:scope) { {} }
    let(:custom_declaration_params) { {} }
    let(:declaration_params) { { clone_with: child_cloner }.merge(custom_declaration_params) }
    let(:params) { { post: { title: 'New post!' } } }
    let(:declaration) do
      Clowne::Declarations::IncludeAssociation.new(:posts, scope, **declaration_params)
    end
    let(:association) { described_class.new(reflection, source, declaration, adapter, params) }

    subject { association.clone_one(child) }

    context 'when params option not defined' do
      it 'clone without params' do
        expect(child_cloner).to receive(:call).with(child, adapter: adapter)

        subject
      end
    end

    context 'when params option is false' do
      let(:custom_declaration_params) { { params: false } }

      it 'clone without params' do
        expect(child_cloner).to receive(:call).with(child, adapter: adapter)

        subject
      end
    end

    context 'when params option is true' do
      let(:custom_declaration_params) { { params: true } }

      it 'clone all params' do
        expect(child_cloner).to receive(:call).with(child, params)

        subject
      end
    end

    context 'when params option is a key' do
      let(:custom_declaration_params) { { params: :post } }

      it 'clone nested params' do
        expect(child_cloner).to receive(:call).with(child, params[:post])

        subject
      end
    end

    context 'when params option is a block' do
      let(:custom_declaration_params) { { params: ->(p) { p.merge(some_stuff: 'ಠᴗಠ') } } }

      it 'clone nested params' do
        expect(child_cloner).to receive(:call).with(
          child,
          adapter: adapter,
          post: { title: 'New post!' },
          some_stuff: 'ಠᴗಠ'
        )

        subject
      end

      context 'with record' do
        let(:custom_declaration_params) do
          {
            params: ->(params, parent) { params.merge(some_stuff: 'ಠᴗಠ', parent: parent) }
          }
        end

        it 'clone nested params' do
          expect(child_cloner).to receive(:call).with(
            child,
            adapter: adapter,
            post: { title: 'New post!' },
            some_stuff: 'ಠᴗಠ',
            parent: source
          )

          subject
        end
      end
    end
  end
end

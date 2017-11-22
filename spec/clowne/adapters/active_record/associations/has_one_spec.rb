describe Clowne::Adapters::ActiveRecord::Associations::HasOne, :cleanup, adapter: :active_record do
  let(:account) { create(:account, :with_history) }
  let(:post) { create(:post, account: account) }
  let(:source) { post }
  let(:declaration_params) { {} }
  let(:record) { Post.new }
  let(:reflection) { Post.reflections['account'] }
  let(:association) { :account }
  let(:declaration) { Clowne::Declarations::IncludeAssociation.new(association, **declaration_params) }
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, params) }

  before(:all) do
    class AccountCloner < Clowne::Cloner
      finalize do |source, record, params|
        record.created_at = source.created_at if params[:include_timestamps]
      end

      nullify :updated_at, :created_at

      include_association :history

      trait :mark_as_clone do
        finalize do |source, record|
          record.title = source.title + ' (Cloned)'
        end
      end
    end

    class HistoryCloner < Clowne::Cloner
      finalize do |source, record, params|
        record.created_at = source.created_at if params[:include_timestamps]
      end

      nullify :updated_at, :created_at

      trait :mark_as_clone do
        finalize do |source, record|
          record.title = source.title + ' (Cloned)'
        end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, 'AccountCloner')
    Object.send(:remove_const, 'HistoryCloner')
  end

  describe '.call' do
    subject { resolver.call(record) }

    it 'infers default cloner from model name' do
      expect(subject.account).to be_new_record
      expect(subject.account).to have_attributes(
        updated_at: nil,
        created_at: nil,
        post_id: nil,
        title: account.title
      )
      expect(subject.account.history).to be_new_record
      expect(subject.account.history).to have_attributes(
        updated_at: nil,
        created_at: nil,
        some_stuff: account.history.some_stuff,
        account_id: nil
      )
    end

    context 'with params' do
      let(:params) { { include_timestamps: true } }

      it 'pass params to child cloner' do
        expect(subject.account).to be_new_record
        expect(subject.account).to have_attributes(
          updated_at: nil,
          created_at: account.created_at,
          post_id: nil,
          title: account.title
        )
        expect(subject.account.history).to be_new_record
        expect(subject.account.history).to have_attributes(
          updated_at: nil,
          created_at: account.history.created_at,
          some_stuff: account.history.some_stuff,
          account_id: nil
        )
      end
    end

    context 'with traits' do
      let(:declaration_params) { { traits: [:mark_as_clone] } }

      it 'includes traits for self' do
        expect(subject.account).to be_new_record
        expect(subject.account).to have_attributes(
          updated_at: nil,
          created_at: nil,
          post_id: nil,
          title: "#{account.title} (Cloned)"
        )
        expect(subject.account.history).to be_new_record
        expect(subject.account.history).to have_attributes(
          updated_at: nil,
          created_at: nil,
          some_stuff: account.history.some_stuff,
          account_id: nil
        )
      end
    end

    context 'with custom cloner' do
      let(:account_cloner) do
        Class.new(Clowne::Cloner) do
          finalize do |source, record, _params|
            record.title = "Copy of #{source.title}"
          end
        end
      end

      let(:declaration_params) { { clone_with: account_cloner } }

      it 'applies custom cloner' do
        expect(subject.account).to be_new_record
        expect(subject.account).to have_attributes(
          post_id: nil,
          title: "Copy of #{account.title}"
        )
        expect(subject.account.history).to be_nil
      end
    end
  end
end

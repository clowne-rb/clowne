describe Clowne::Adapters::Sequel::Associations::OneToOne, :cleanup, adapter: :sequel do
  let(:post) { create('sequel:post') }
  let!(:account) { create('sequel:account', :with_history, post: post) }
  let(:source) { post }
  let(:declaration_params) { {} }
  let(:record) { Clowne::Adapters::Sequel::RecordWrapper.new(Sequel::Post.new) }
  let(:reflection) { Sequel::Post.association_reflections[:account] }
  let(:association) { :account }
  let(:declaration) do
    Clowne::Declarations::IncludeAssociation.new(association, **declaration_params)
  end
  let(:params) { {} }

  subject(:resolver) { described_class.new(reflection, source, declaration, params) }

  before(:all) do
    module Sequel
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
  end

  after(:all) do
    Sequel.send(:remove_const, 'AccountCloner')
    Sequel.send(:remove_const, 'HistoryCloner')
  end

  describe '.call' do
    subject { resolver.call(record).to_model }

    it 'infers default cloner from model name' do
      expect(subject.account).to be_new
      expect(subject.account).to be_a(Sequel::Account)
      expect(subject.account.to_hash).to eq(
        post_id: nil,
        title: account.title,
        created_at: nil,
        updated_at: nil
      )
      expect(subject.account.history).to be_new
      expect(subject.account.history.to_hash).to eq(
        some_stuff: account.history.some_stuff,
        account_id: nil,
        created_at: nil,
        updated_at: nil
      )
    end

    context 'with params' do
      let(:params) { { include_timestamps: true } }

      it 'pass params to child cloner' do
        expect(subject.account).to be_new
        expect(subject.account.to_hash).to include(
          created_at: account.created_at,
          post_id: nil,
          title: account.title
        )
        expect(subject.account.history).to be_new
        expect(subject.account.history.to_hash).to include(
          created_at: account.history.created_at,
          some_stuff: account.history.some_stuff,
          account_id: nil
        )
      end
    end

    context 'with traits' do
      let(:declaration_params) { { traits: [:mark_as_clone] } }

      it 'includes traits for self' do
        expect(subject.account).to be_new
        expect(subject.account.to_hash).to include(
          post_id: nil,
          title: "#{account.title} (Cloned)"
        )
        expect(subject.account.history).to be_new
        expect(subject.account.history.to_hash).to include(
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
        expect(subject.account).to be_new
        expect(subject.account.to_hash).to include(
          post_id: nil,
          title: "Copy of #{account.title}"
        )
        expect(subject.account.history).to be_nil
      end
    end
  end
end

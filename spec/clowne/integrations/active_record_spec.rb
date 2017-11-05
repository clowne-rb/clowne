RSpec.describe 'oGod spec for AR adapter' do
  class AccountCloner < Clowne::Cloner
    adapter Clowne::ActiveRecordAdapter::Adapter

    include_all

    trait :with_history do
      exclude_association :history
      include_association :history
    end

    trait :nullify_title do
      nullify :title
    end
  end

  class BasePostCloner < Clowne::Cloner
    adapter Clowne::ActiveRecordAdapter::Adapter

    finalize do |_source, record, params|
      record.contents = params[:post_contents]
    end
  end

  class PostCloner < BasePostCloner
    include_association :account, clone_with: AccountCloner, traits: %i[with_history nullify_title]
    include_association :tags, ->(params) { where(value: params[:tags]) }

    trait :mark_as_clone do
      finalize do |source, record|
        record.title = source.title + ' Super!'
      end
    end
  end

  before do
    ActiveRecord::Base.subclasses.each(&:delete_all)

    class HistoryCloner < Clowne::Cloner
      adapter Clowne::ActiveRecordAdapter::Adapter

      finalize do |_source, record|
        record.some_stuff = record.some_stuff + ' - 2'
      end
    end
  end

  let!(:source) { Post.create(title: 'TeamCity') }
  let!(:account) { Account.create(title: 'Manager', post: source) }
  let!(:history) { History.create(some_stuff: 'This is history about my life', account: account) }

  before do
    tags = %w[CI CD JVM].map { |value| Tag.create(value: value) }
    source.tags = tags
    source.save
  end

  it 'clone all stuff', cleanup: true do
    expect(Post.count).to eq(1)
    expect(Tag.count).to eq(3)
    expect(Account.count).to eq(1)
    expect(History.count).to eq(1)

    clone = PostCloner.call(
      source,
      traits: :mark_as_clone,
      tags: %w[CI CD],
      post_contents: 'THIS IS CLONE! (☉_☉)'
    )
    clone.save!

    expect(Post.count).to eq(2)
    expect(Tag.count).to eq(5)
    expect(Account.count).to eq(2)
    expect(History.count).to eq(2)

    # post
    expect(clone).to be_a(Post)
    expect(clone.title).to eq('TeamCity Super!')
    expect(clone.contents).to eq('THIS IS CLONE! (☉_☉)')

    # account
    account_clone = clone.account
    expect(account_clone).to be_a(Account)
    expect(account_clone.title).to be_nil
    expect(account_clone.history).to be_a(History)

    # history
    history_clone = account_clone.history
    expect(history_clone.some_stuff).to eq('This is history about my life - 2')

    # tags
    tags_clone = clone.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD])
  end
end

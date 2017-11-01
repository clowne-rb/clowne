RSpec.describe 'oGod spec for AR adapter' do
  class AccountCloner < Clowne::Cloner
    exclude_association :history

    trait :with_history do
      include_association :history
    end

    trait :nullify_title do
      nullify :title
    end
  end

  class PostCloner < Clowne::Cloner
    adapter Clowne::ActiveRecordAdapter::Adapter

    include_all

    include_association :account, clone_with: AccountCloner, for: [:with_history, :nullify_title]
    include_association :tags, -> (params) { where(value: params[:tags]) }

    trait :mark_as_clone do
      finalize do |source, record, params|
        record.title = source.title + ' Super!'
        record.contents = params[:post_contents]
      end
    end
  end

  before { ActiveRecord::Base.subclasses.each(&:delete_all) }

  let!(:source) { Post.create(title: 'TeamCity') }
  let!(:account) { Account.create(title: 'Manager', post: source) }
  let!(:history) { History.create(some_stuff: 'This is history about my life', account: account) }

  before do
    tags = %w(CI CD JVM).map { |value| Tag.create(value: value) }
    source.tags = tags
    source.save
  end

  it 'clone all stuff' do
    expect(Post.count).to eq(1)
    expect(Tag.count).to eq(3)
    expect(Account.count).to eq(1)
    expect(History.count).to eq(1)

    clone = PostCloner.call(source,
      for: :mark_as_clone,
      tags: %w(CI CD),
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
    expect(history_clone.some_stuff).to eq(history.some_stuff)

    # tags
    tags_clone = clone.tags
    expect(tags_clone.map(&:value)).to match_array(%w(CI CD))
  end
end

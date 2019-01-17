describe 'Sequel adapter', :cleanup, adapter: :sequel, transactional: :sequel do
  before(:all) do
    module Sequel
      class AccCloner < Clowne::Cloner
        exclude_association :history

        trait :with_history do
          include_association :history
        end

        trait :nullify_title do
          nullify :title
        end
      end

      class BasePostCloner < Clowne::Cloner
        finalize do |_source, record, params|
          record.contents = params[:post_contents] if params[:post_contents].present?
        end
      end

      class PostCloner < BasePostCloner
        include_association :account, clone_with: 'Sequel::AccCloner',
                                      traits: %i[with_history nullify_title]
        include_association :tags, ->(params) { where(value: params[:tags]) if params[:tags] }

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + ' Super!'
          end
        end

        trait :copy do
          init_as do |source, target:|
            target.contents = source.contents
            target
          end
        end
      end

      class HistoryCloner < Clowne::Cloner
        finalize do |_source, record|
          record.some_stuff = record.some_stuff + ' - 2'
        end
      end
    end
  end

  after(:all) do
    %w[AccCloner BasePostCloner PostCloner HistoryCloner].each do |cloner|
      Sequel.send(:remove_const, cloner)
    end
  end

  let!(:post) { create('sequel:post', title: 'TeamCity') }
  let!(:account) { create('sequel:account', title: 'Manager', post: post) }
  let!(:history) do
    create('sequel:history', some_stuff: 'This is history about my life', account: account)
  end
  let(:topic) { post.topic }

  let!(:tags) do
    %w[CI CD JVM].map { |value| create('sequel:tag', value: value) }.tap do |items|
      items.each { |tag| post.add_tag(tag) }
    end
  end

  it 'clone all stuff' do
    expect(Sequel::Topic.count).to eq(1)
    expect(Sequel::Post.count).to eq(1)
    expect(Sequel::Tag.count).to eq(3)
    expect(Sequel::Account.count).to eq(1)
    expect(Sequel::History.count).to eq(1)

    cloned_wrapper = Sequel::PostCloner.call(
      post,
      traits: :mark_as_clone,
      tags: %w[CI CD],
      post_contents: 'THIS IS CLONE! (☉_☉)'
    )
    cloned = cloned_wrapper.persist

    expect(Sequel::Topic.count).to eq(1)
    expect(Sequel::Post.count).to eq(2)
    expect(Sequel::Tag.count).to eq(5)
    expect(Sequel::Account.count).to eq(2)
    expect(Sequel::History.count).to eq(2)

    # post
    expect(cloned).to be_a(Sequel::Post)
    expect(cloned.title).to eq('TeamCity Super!')
    expect(cloned.contents).to eq('THIS IS CLONE! (☉_☉)')

    # account
    account_clone = cloned.account
    expect(account_clone).to be_a(Sequel::Account)
    expect(account_clone.title).to be_nil
    expect(account_clone.history).to be_a(Sequel::History)

    # history
    history_clone = account_clone.history
    expect(history_clone.some_stuff).to eq('This is history about my life - 2')

    # tags
    tags_clone = cloned.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD])
  end

  it 'works with existing post', :aggregate_failures do
    a_post = create('sequel:post', title: 'Thing').tap do |p|
      p.add_tag create('sequel:tag', value: 'ROM')
    end

    expect(Sequel::Topic.count).to eq(2)
    expect(Sequel::Post.count).to eq(2)
    expect(Sequel::Tag.count).to eq(4)
    expect(Sequel::Account.count).to eq(1)
    expect(Sequel::History.count).to eq(1)

    cloned_wrapper = Sequel::PostCloner.call(
      post,
      traits: :copy,
      target: a_post
    )

    cloned = cloned_wrapper.persist

    expect(cloned).to be_eql(a_post)

    expect(Sequel::Topic.count).to eq(2)
    expect(Sequel::Post.count).to eq(2)
    expect(Sequel::Tag.count).to eq(7)
    expect(Sequel::Account.count).to eq(2)
    expect(Sequel::History.count).to eq(2)

    # post
    expect(a_post).to be_a(Sequel::Post)
    expect(a_post.title).to eq('Thing')
    expect(a_post.contents).to eq(post.contents)

    # history
    history_clone = a_post.account.history
    expect(history_clone.some_stuff).to eq('This is history about my life - 2')

    # tags
    tags_clone = a_post.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD JVM ROM])
  end
end

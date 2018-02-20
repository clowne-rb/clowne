describe 'AR adapter', :cleanup, adapter: :active_record, transactional: :active_record do
  before(:all) do
    module AR
      class AccCloner < Clowne::Cloner
        trait :with_history do
          include_association :history, params: :history
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
        include_association :account, clone_with: 'AR::AccCloner',
                                      traits: %i[with_history nullify_title],
                                      params: true
        include_association :tags, ->(params) { where(value: params[:tags]) if params[:tags] }

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + ' Super!'
          end
        end

        trait :copy do
          init_as do |source, target:, **|
            target.contents = source.contents
            target
          end
        end
      end

      class HistoryCloner < Clowne::Cloner
        finalize do |_source, record, suffix:|
          record.some_stuff = record.some_stuff + suffix
        end
      end
    end
  end

  after(:all) do
    %w[AccCloner BasePostCloner PostCloner HistoryCloner].each do |cloner|
      AR.send(:remove_const, cloner)
    end
  end

  let!(:account) { create(:account, title: 'Manager') }
  let!(:history) { create(:history, some_stuff: 'This is history about my life', account: account) }
  let!(:post) { create(:post, title: 'TeamCity', account: account) }
  let(:topic) { post.topic }

  let!(:tags) do
    %w[CI CD JVM].map { |value| create(:tag, value: value) }.tap do |items|
      post.tags = items
    end
  end

  it 'clone all stuff' do
    expect(AR::Topic.count).to eq(1)
    expect(AR::Post.count).to eq(1)
    expect(AR::Tag.count).to eq(3)
    expect(AR::Account.count).to eq(1)
    expect(AR::History.count).to eq(1)

    cloned = AR::PostCloner.call(
      post,
      traits: :mark_as_clone,
      tags: %w[CI CD],
      post_contents: 'THIS IS CLONE! (☉_☉)',
      history: { suffix: ' - 2' }
    )
    cloned.save!

    expect(AR::Topic.count).to eq(1)
    expect(AR::Post.count).to eq(2)
    expect(AR::Tag.count).to eq(5)
    expect(AR::Account.count).to eq(2)
    expect(AR::History.count).to eq(2)

    # post
    expect(cloned).to be_a(AR::Post)
    expect(cloned.title).to eq('TeamCity Super!')
    expect(cloned.contents).to eq('THIS IS CLONE! (☉_☉)')

    # account
    account_clone = cloned.account
    expect(account_clone).to be_a(AR::Account)
    expect(account_clone.title).to be_nil
    expect(account_clone.history).to be_a(AR::History)

    # history
    history_clone = account_clone.history
    expect(history_clone.some_stuff).to eq('This is history about my life - 2')

    # tags
    tags_clone = cloned.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD])
  end

  it 'works with existing post' do
    a_post = create(:post, title: 'Thing').tap do |p|
      p.tags << create(:tag, value: 'RUM')
    end

    expect(AR::Topic.count).to eq(2)
    expect(AR::Post.count).to eq(2)
    expect(AR::Tag.count).to eq(4)
    expect(AR::Account.count).to eq(2)
    expect(AR::History.count).to eq(1)

    cloned = AR::PostCloner.call(
      post,
      traits: :copy,
      target: a_post,
      history: { suffix: ' - 3' }
    )
    cloned.save!

    expect(cloned).to be_eql(a_post)

    expect(AR::Topic.count).to eq(2)
    expect(AR::Post.count).to eq(2)
    expect(AR::Tag.count).to eq(7)
    expect(AR::Account.count).to eq(3)
    expect(AR::History.count).to eq(2)

    # post
    expect(a_post.title).to eq('Thing')
    expect(a_post.contents).to eq(post.contents)

    # history
    history_clone = a_post.account.history
    expect(history_clone.some_stuff).to eq('This is history about my life - 3')

    # tags
    tags_clone = a_post.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD JVM RUM])
  end

  it 'works with partial clone' do
    cloned = AR::PostCloner.partial_apply(
      { association: :tags },
      post,
      traits: :mark_as_clone,
      tags: %w[CI CD]
    )

    cloned.save!
    cloned.reload

    # title
    expect(cloned.title).to eq post.title

    # account
    expect(cloned.account).to be_nil

    # tags
    tags_clone = cloned.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD])
  end
end

FactoryBot.define do
  to_create(&:save)

  factory 'sequel:user', class: 'Sequel::User' do
    sequence(:name) { |n| "John #{n}" }
    sequence(:email) { |n| "clowne_#{n}@test.rb" }

    transient do
      posts_num 2
    end

    trait :with_posts do
      after(:create) do |user, ev|
        create_list('sequel:post', ev.posts_num, owner: user)
      end
    end
  end

  factory 'sequel:post', class: 'Sequel::Post' do
    sequence(:title) { |n| "Post ##{n}" }
    sequence(:contents) { |n| "About a number #{n}" }

    association :owner, factory: 'sequel:user'
    association :topic, factory: 'sequel:topic'

    transient do
      tags_num 2
    end

    trait :with_tags do
      after(:create) do |post, ev|
        create_list('sequel:tag', ev.tags_num).each do |tag|
          tag.add_post(post)
        end
      end
    end
  end

  factory 'sequel:account', class: 'Sequel::Account' do
    sequence(:title) { |n| "Account ##{n}" }

    trait :with_history do
      after(:create) { |account| create('sequel:history', account: account) }
    end
  end

  factory 'sequel:history', class: 'Sequel::History' do
    sequence(:some_stuff) { |n| "Bla-bla #{n}" }

    association :account, factory: 'sequel:account'
  end

  factory 'sequel:topic', class: 'Sequel::Topic' do
    sequence(:title) { |n| "Topic ##{n}}" }
    sequence(:description) { |n| "Let's talk about #{n}" }

    transient do
      posts_num 2
    end

    trait :with_posts do
      after(:create) do |topic, ev|
        create_list('sequel:post', ev.posts_num, topic: topic)
      end
    end
  end

  factory 'sequel:tag', class: 'Sequel::Tag' do
    sequence(:value) { |n| "T#{n}" }

    transient do
      posts_num 2
    end

    trait :with_posts do
      after(:create) do |tag, ev|
        create_list('sequel:post', ev.posts_num, tags: [tag])
      end
    end
  end
end

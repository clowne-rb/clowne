FactoryBot.define do
  factory :user, class: 'AR::User' do
    sequence(:name) { |n| "John #{n}" }
    sequence(:email) { |n| "clowne_#{n}@test.rb" }

    transient do
      posts_num 2
    end

    trait :with_posts do
      after(:create) do |user, ev|
        create_list(:post, ev.posts_num, owner: user)
      end
    end
  end

  factory :post, class: 'AR::Post' do
    sequence(:title) { |n| "Post ##{n}" }
    sequence(:contents) { |n| "About a number #{n}" }

    association :owner, factory: :user
    account
    topic

    transient do
      tags_num 2
    end

    trait :with_tags do
      after(:create) do |post, ev|
        create_list(:tag, ev.tags_num, posts: [post])
      end
    end
  end

  factory :account, class: 'AR::Account' do
    sequence(:title) { |n| "Account ##{n}" }

    trait :with_history do
      after(:create) { |account| create(:history, account: account) }
    end
  end

  factory :history, class: 'AR::History' do
    sequence(:some_stuff) { |n| "Bla-bla #{n}" }

    account
  end

  factory :topic, class: 'AR::Topic' do
    sequence(:title) { |n| "Topic ##{n}}" }
    sequence(:description) { |n| "Let's talk about #{n}" }

    transient do
      posts_num 2
    end

    trait :with_posts do
      after(:create) do |topic, ev|
        create_list(:post, ev.posts_num, topic: topic)
      end
    end
  end

  factory :tag, class: 'AR::Tag' do
    sequence(:value) { |n| "T#{n}" }

    transient do
      posts_num 2
    end

    trait :with_posts do
      after(:create) do |tag, ev|
        create_list(:post, ev.posts_num, tags: [tag])
      end
    end
  end
end

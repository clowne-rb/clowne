FactoryBot.define do
  to_create(&:save)

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

  factory 'sequel:image', class: 'Sequel::Image' do
    sequence(:title) { |n| "Image  ##{n}" }

    trait :with_preview_image do
      after(:create) { |image| create('sequel:preview_image', image: image) }
    end
  end

  factory 'sequel:preview_image', class: 'Sequel::PreviewImage' do
    sequence(:some_stuff) { |n| "Bla-bla #{n}" }

    association :image, factory: 'sequel:image'
  end

  factory 'sequel:tag', class: 'Sequel::Tag' do
    sequence(:value) { |n| "T#{n}" }

    transient do
      posts_num 2
    end

    trait :with_posts do
      after(:create) do |tag, ev|
        create_list('sequel:post', ev.posts_num).each do |post|
          post.add_tag(tag)
        end
      end
    end
  end
end

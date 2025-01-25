# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: "AR::User" do
    sequence(:name) { |n| "John #{n}" }
    sequence(:email) { |n| "clowne_#{n}@test.rb" }

    transient do
      posts_num { 2 }
    end

    trait :with_posts do
      after(:create) do |user, ev|
        create_list(:post, ev.posts_num, owner: user)
      end
    end
  end

  factory :post, class: "AR::Post" do
    sequence(:title) { |n| "Post ##{n}" }
    sequence(:contents) { |n| "About a number #{n}" }

    association :owner, factory: :user
    image
    topic

    transient do
      tags_num { 2 }
    end

    trait :with_tags do
      after(:create) do |post, ev|
        create_list(:tag, ev.tags_num, posts: [post])
      end
    end
  end

  factory :image, class: "AR::Image" do
    sequence(:title) { |n| "Image ##{n}" }

    trait :with_preview_image do
      after(:create) { |image| create(:preview_image, image: image) }
    end
  end

  factory :preview_image, class: "AR::PreviewImage" do
    sequence(:some_stuff) { |n| "Bla-bla #{n}" }

    image
  end

  factory :topic, class: "AR::Topic" do
    sequence(:title) { |n| "Topic ##{n}}" }
    sequence(:description) { |n| "Let's talk about #{n}" }

    transient do
      posts_num { 2 }
    end

    trait :with_posts do
      after(:create) do |topic, ev|
        create_list(:post, ev.posts_num, topic: topic)
      end
    end
  end

  factory :tag, class: "AR::Tag" do
    sequence(:value) { |n| "T#{n}" }

    transient do
      posts_num { 2 }
    end

    trait :with_posts do
      after(:create) do |tag, ev|
        create_list(:post, ev.posts_num, tags: [tag])
      end
    end
  end

  factory :table, class: "AR::Table" do
    sequence(:title) { |n| "T#{n}" }
  end

  factory :row, class: "AR::Row" do
    sequence(:title) { |n| "R#{n}" }
  end

  factory :column, class: "AR::Column" do
    sequence(:title) { |n| "C#{n}" }
  end

  factory :cell, class: "AR::Cell" do
  end
end

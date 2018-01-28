---
id: testing
title: Testing
---

Clowne provides specific tools to help you test your cloners.

The main goal is to make it possible to test different cloning phases separately and avoid _heavy_ tests setup phases.

Let's consider the following models and cloners:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one :profile
  has_many :posts
end

# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments
  has_many :votes

  scope :draft, -> { where(draft: true) }
end

# app/cloners/user_cloner.rb
class UserCloner < Clowne::Cloner
  class ProfileCloner
    nullify :rating
  end

  include_association :profile, clone_with: ProfileCloner

  nullify :email

  finalize do |_, record, name: nil|
    record.name = name unless name.nil?
  end

  trait :copy do
    init_as do |user, target:|
      # copy name
      target.name = user.name
      target
    end
  end

  trait :with_posts do
    include_association :posts, scope: :draft
  end

  trait :with_popular_posts do
    include_association :posts, (lambda do |params|
      where('rating > ?', params[:min_rating])
    end)
  end
end

# app/cloners/post_cloner.rb
class PostCloner < Clowne::Cloner
  include_association :comments
end
```

## Getting started

Currently, only [RSpec](http://rspec.info/) is supported.

Add this line to your `spec_helper.rb` (or `rails_helper.rb`):

```ruby
require 'clowne/rspec'
```

## Configuration matchers

There are several matchers that allow you to verify the cloner configuration.

### `have_included_associations`

This matcher vefifies that your cloner includes the specified associations:

```ruby
# spec/cloners/user_cloner_spec.rb
RSpec.describe UserCloner, type: :cloner do
  subject { described_class }

  specify do
    # checks that only the specified associations is included
    is_expected.to have_included_associations(:profile)

    # with traits
    is_expected.to have_included_associations(:profile, :posts)
      .with_traits(:with_posts)

    # raises when there are some unspecified associations
    is_expected.to have_included_associations(:profile)
      .with_traits(:with_posts)
    #=> raises RSpec::Expectations::ExpectationNotMetError
  end
end
```

### `have_included_association`

This matcher allows to verify the specified association options:

```ruby
# spec/cloners/user_cloner_spec.rb
RSpec.describe UserCloner, type: :cloner do
  subject { described_class }

  specify do
    # simply check that association is included
    is_expected.to have_included_association(:profile)

    # check options
    is_expected.to have_included_association(:profile)
      .with_cloner(described_class::PostCloner)

    # with traits, scope and implicit cloner
    is_expected.to have_included_association(:posts)
      .with_traits(:with_posts)
      .with_cloner(::PostCloner)
      .with_scope(:draft)
  end
end
```

## Clone actions matchers

Under the hood, Clowne builds a [compilation plan](architecture.md) which is used to clone the record.

Plan is a set of _actions_ (such as `nullify`, `finalize`, `association`, `init_as`) which are applied to the record.

Most of the time these actions don't depend on each other, thus we can test them separately:

```ruby
# spec/cloners/user_cloner_spec.rb
RSpec.describe UserCloner, type: :cloner do
  subject(:user) { create :user, name: 'Bombon' }

  specify 'simple case' do
    plan = clowne_plan(described_class, user)
    # apply only the specified part of the plan
    cloned_user = plan.apply(:nullify)
    expect(cloned_user.email).to be_nil
    # finalize wasn't applied
    expect(cloned_user.name).to eq 'Bombon'
  end

  specify 'with params' do
    plan = clowne_plan(described_class, user, name: 'new name')

    cloned_user = plan.apply(:finalize)
    # nullify actions were not applied!
    expect(cloned_user.email).to eq user.email
    # finalize was applied
    expect(cloned_user.name).to eq 'new name'
  end

  specify 'with traits' do
    a_user = create(:user, name: 'Dindon')
    plan = clowne_plan(described_class, user, traits: :copy, target: a_user)
    cloned_user = plan.apply(:init_as)
    # returned user is the same as target
    expect(cloned_user).to be_eql(a_user)
    expect(cloned_user.name).to eq 'Bombon'
  end

  specify 'associations' do
    create(:post, user: user, rating: 1, text: 'Boom Boom')
    create(:post, user: user, rating: 2, text: 'Flying Dumplings')

    plan = clowne_plan(described_class,
                       user, traits: :with_popular_posts, min_rating: 1)
    # you can specify which associations to include (you can use array)
    # to apply all associations write:
    #   plan.apply(:association)
    cloned_user = plan.apply(association: :posts)
    expect(cloned_user.posts.size).to eq 1
    expect(cloned_user.posts.first.text).to eq 'Flying Dumplings'
  end
end
```

**NOTE:** `clowne_plan` method is only available in groups marked with `type: :cloner` tag.
Clowne automaticaly marks all specs in `spec/cloners` folder with `type: :cloner`. Otherwise you have to add this tag yourself.

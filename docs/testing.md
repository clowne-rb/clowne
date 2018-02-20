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
    include_association :posts, :draft, traits: :mark_as_copy
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

  trait :mark_as_copy do |_, record|
    record.title += " (copy)"
  end
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

### `clone_associations`

This matcher vefifies that your cloner includes the specified associations:

```ruby
# spec/cloners/user_cloner_spec.rb
RSpec.describe UserCloner, type: :cloner do
  subject { described_class }

  specify do
    # checks that only the specified associations is included
    is_expected.to clone_associations(:profile)

    # with traits
    is_expected.to clone_associations(:profile, :posts)
      .with_traits(:with_posts)

    # raises when there are some unspecified associations
    is_expected.to clone_associations(:profile)
      .with_traits(:with_posts)
    #=> raises RSpec::Expectations::ExpectationNotMetError
  end
end
```

### `clone_association`

This matcher allows to verify the specified association options:

```ruby
# spec/cloners/user_cloner_spec.rb
RSpec.describe UserCloner, type: :cloner do
  subject { described_class }

  specify do
    # simply check that association is included
    is_expected.to clone_association(:profile)

    # check options
    is_expected.to clone_association(
      :profile,
      clone_with: described_class::ProfileCloner
    )

    # with traits, scope and activated trait
    is_expected.to clone_association(
      :posts,
      traits: :mark_as_copy,
      scope: :draft
    ).with_traits(:with_posts)
  end
end
```

**NOTE:** `clone_associations`/`clone_association` matchers are only available in groups marked with `type: :cloner` tag.

Clowne automaticaly marks all specs in `spec/cloners` folder with `type: :cloner`. Otherwise you have to add this tag you.


## Clone actions matchers

Under the hood, Clowne builds a [compilation plan](architecture.md) which is used to clone the record.

Plan is a set of _actions_ (such as `nullify`, `finalize`, `association`, `init_as`) which are applied to the record.

Most of the time these actions don't depend on each other, thus we can test them separately:

```ruby
# spec/cloners/user_cloner_spec.rb
RSpec.describe UserCloner, type: :cloner do
  subject(:user) { create :user, name: 'Bombon' }

  specify 'simple case' do
    # apply only the specified part of the plan
    cloned_user = described_class.partial_apply(:nullify, user)
    expect(cloned_user.email).to be_nil
    # finalize wasn't applied
    expect(cloned_user.name).to eq 'Bombon'
  end

  specify 'with params' do
    cloned_user = described_class.partial_apply(:finalize, user, name: 'new name')
    # nullify actions were not applied!
    expect(cloned_user.email).to eq user.email
    # finalize was applied
    expect(cloned_user.name).to eq 'new name'
  end

  specify 'with traits' do
    a_user = create(:user, name: 'Dindon')
    cloned_user = described_class.partial_apply(:init_as, user, traits: :copy, target: a_user)
    # returned user is the same as target
    expect(cloned_user).to be_eql(a_user)
    expect(cloned_user.name).to eq 'Bombon'
  end

  specify 'associations' do
    create(:post, user: user, rating: 1, text: 'Boom Boom')
    create(:post, user: user, rating: 2, text: 'Flying Dumplings')

    # you can specify which associations to include (you can use array)
    # to apply all associations write:
    #   plan.apply(:association)
    cloned_user = described_class.apply(
      association: :posts, user, traits: :with_popular_posts, min_rating: 1
    )
    expect(cloned_user.posts.size).to eq 1
    expect(cloned_user.posts.first.text).to eq 'Flying Dumplings'
  end
end
```

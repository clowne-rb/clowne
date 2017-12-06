[![Gem Version](https://badge.fury.io/rb/clowne.svg)](https://badge.fury.io/rb/clowne)
[![Build Status](https://travis-ci.org/palkan/clowne.svg?branch=master)](https://travis-ci.org/palkan/clowne)
[![Code Climate](https://codeclimate.com/github/palkan/clowne.svg)](https://codeclimate.com/github/palkan/clowne)
[![Test Coverage](https://codeclimate.com/github/palkan/clowne/badges/coverage.svg)](https://codeclimate.com/github/palkan/clowne/coverage)

# Clowne

**NOTICE**: gem is currently under heavy development, we plan to release the first version 'till the end of the year.

A flexible gem for cloning your models. Clowne focuses on ease of use and provides the ability to connect various ORM adapters (see [supported adapters](#adapters)).

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

### Alternatives

Why did we decide to build our own cloning gem?

First, existing solutions turned out not stable and flexible enough for us.

Secondly, they are Rails-only. And we are not.

Nevertheless, thanks to [amoeba](https://github.com/amoeba-rb/amoeba) and [deep_cloneable](https://github.com/moiristo/deep_cloneable) for inspiration.

## Installation

To install Clowne with RubyGems:

```ruby
gem install clowne
```

Or add this line to your application's Gemfile:

```ruby
gem 'clowne'
```

## Quick Start

This is a basic example that demonstrates how to clone your ActiveRecord model. For detailed documentation see [Features](#features).

At first, define your cloneable model

```ruby
class User < ActiveRecord::Base
  # create_table :users do |t|
  #  t.string :login
  #  t.string :email
  #  t.timestamps null: false
  # end

  has_one :profile
  has_many :posts
end
```

The next step is to declare cloner

```ruby
class UserCloner < Clowne::Cloner
  adapter :active_record

  include_association :profile, clone_with: SpecialProfileCloner
  include_association :posts

  nullify :login

  # params here is an arbitrary hash passed into cloner
  finalize do |_source, record, params|
    record.email = params[:email]
  end
end

class SpecialProfileCloner < Clowne::Cloner
  adapter :active_record

  nullify :name
end
```

and call it

```ruby
clone = UserCloner.call(User.last, { email: "fake@example.com" })
clone.persisted?
# => false
clone.save!
clone.login
# => nil
clone.email
# => "fake@example.com"

# associations:
clone.posts.count == User.last.posts.count
# => true
clone.profile.name
# => nil
```

## <a name="adapters">Supported adapters

Clowne supports following ORM adapters and associations

Adapter                                   |1:1         | 1:M         | M:M                     |
------------------------------------------|------------|-------------|-------------------------|
[Active Record](#adapter_active_record)   | has_one    | has_many    | has_and_belongs_to_many |
[Sequel](#adapter_sequel)                 | one_to_one | one_to_many | many_to_many            |

### <a name="adapter_active_record">Active Record

Everything works "out of box" ツ

### <a name="adapter_sequel">Sequel

Clowne uses Sequel [NestedAttributes plugin](http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/NestedAttributes.html) for cloning source's assocations and you need to configure it.

Example:

```ruby
class UserCloner < Clowne::Cloner
  adapter :sequel

  include_association :account
end

class User < Sequel::Model
  plugin :nested_attributes

  one_to_one :account
  nested_attributes :account
end
```

If you try to clone associations without NestedAttributes plugin Clowne will skip this declaration.

## <a name="features">Features

- [Configuration](#configuration)
- [Include one association](#include_association)
- - [Scope](#include_association_scope)
- - [Options](#include_association_options)
- [Exclude association](#exclude_association)
- [Nullify attribute(s)](#nullify)
- [Execute finalize block](#finalize)
- [Traits](#traits)
- [Execution order](#execution_order)

### <a name="configuration"></a>Configuration

You can configure the default adapter for cloners:

```ruby
# somewhere in initializers
Clowne.default_adapter = :active_record
```

### <a name="include_association"></a>Include one association

Powerful declaration for including model's association.

```ruby
class User < ActiveRecord::Base
  has_one :profile
end

class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  include_association :profile
end
```

But it's not all! :) The DSL looks like

```ruby
include_association name, scope, options
```

#### <a name="include_association_scope"></a>Include one association: Scope
Scope can be a:

`Symbol` - named scope.

`Proc` - custom scope (supports parameter passing).

Example:

```ruby
class User < ActiveRecord::Base
  has_many :accounts
  has_many :posts
end

class Account < ActiveRecord::Base
  scope :active, -> where(active: true)
end

class Post < ActiveRecord::Base
  # t.string :status
end

class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  include_association :accounts, :active
  include_association :posts, ->(params) { where(state: params[:post_status] }
end

# posts will be cloned only with draft status
UserCloner.call(user, { post_status: :draft })
# => <#User...
```

#### <a name="include_association_options"></a>Include one association: Options

Options keys can be a:

`:clone_with` - use custom cloner for all children.

`:traits` - define special traits.

Example:

```ruby
class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  # t.string :title
  has_many :tags
end
```

```ruby
class PostSpecialCloner < Clowne::Cloner
  adapter :active_record

  nullify :title

  trait :with_tags do
    include_association :tags
  end
end

class UserCloner < Clowne::Cloner
  adapter :active_record

  include_association :posts, clone_with: PostSpecialCloner
  # or clone user's posts with tags!
  # include_association :posts, clone_with: PostSpecialCloner, traits: :with_tags
end

UserCloner.call(user)
# => <#User...
```

**Notice: if custom cloner is not defined, clowne tries to find default cloner and use it. (PostCloner for previous example)**

### <a name="exclude_association"></a>Exclude association

Exclude association from copying

```ruby
class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  include_association :posts

  trait :without_posts do
    exclude_association :posts
  end
end

# copy user and posts
clone = UserCloner.call(user)
clone.posts.count == user.posts.count
# => true

# copy only user
clone2 = UserCloner.call(user, traits: :without_posts)
clone2.posts
# => []
```

### <a name="nullify"></a>Nullify attribute(s)

Nullify attributes:

```ruby
class User < ActiveRecord::Base
  # t.string :name
  # t.string :surename
  # t.string :email
end

class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  nullify :name, :email

  trait :nullify_surename do
    nullify :surename
  end
end

# nullify only name
clone = UserCloner.call(user)
clone.name.nil?
# => true
clone.email.nil?
# => true
clone.surename.nil?
# => false

# nullify name and surename
clone2 = UserCloner.call(user, traits: :nullify_surename)
clone.name.nil?
# => true
clone.surename.nil?
# => true
```

### <a name="finalize"></a>Execute finalize block

Simple callback for changing record manually.

```ruby
class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  finalize do |source, record, params|
    record.name = 'This is copy!'
  end

  trait :change_email do
    finalize do |source, record, params|
      record.email = params[:email]
    end
  end
end

# execute first finalize
clone = UserCloner.call(user)
clone.name
# => 'This is copy!'
clone.email == 'clone@example.com'
# => false

# execute both finalizes
clone2 = UserCloner.call(user, traits: :change_email)
clone.name
# => 'This is copy!'
clone.email
# => 'clone@example.com'
```

### <a name="traits"></a>Traits

Traits allow you to group cloner declarations together and then apply them (like in factory_bot).

```ruby
class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  trait :with_posts do
    include_association :posts
  end

  trait :with_profile do
    include_association :profile
  end

  trait :nullify_name do
    nullify :name
  end
end

# execute first finalize
UserCloner.call(user, traits: [:with_posts, :with_profile, :nullify_name])
# or
UserCloner.call(user, traits: :nullify_name)
# or
# ...
```

### <a name="execution_order"></a>Execution order

The order of cloning actions depends on the adapter.

For ActiveRecord:
- clone associations
- nullify attributes
- run `finalize` blocks

The order of `finalize` blocks is the order they've been written.

*NOTE*: using a trait means appending the trait's rules to the main execution plan.

## Maintainers

- [Vladimir Dementyev](https://github.com/palkan)

- [Sverchkov Nikolay](https://github.com/ssnickolay)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

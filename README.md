[![Gem Version](https://badge.fury.io/rb/clowne.svg)](https://badge.fury.io/rb/clowne)
[![Build Status](https://travis-ci.org/palkan/clowne.svg?branch=master)](https://travis-ci.org/palkan/clowne)
[![Code Climate](https://codeclimate.com/github/palkan/clowne.svg)](https://codeclimate.com/github/palkan/clowne)
[![Test Coverage](https://codeclimate.com/github/palkan/clowne/badges/coverage.svg)](https://codeclimate.com/github/palkan/clowne/coverage)

# Clowne

**NOTICE**: gem is currently under heavy development, we plan to release the first version 'till the end of the year.

A flexible gem for cloning your models. Clowne focuses on ease of use and provides the ability to connect various ORM adapters (currently only ActiveRecord is supported).

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
cloned = UserCloner.call(User.last, { email: "fake@example.com" })
cloned.persisted?
# => false
cloned.save!
cloned.login
# => nil
cloned.email
# => "fake@example.com"

# associations:
cloned.posts.count == User.last.posts.count
# => true
cloned.profile.name
# => nil
```

## <a name="features">Features

- [Configuration](#configuration)
- [Include association](#include_association)
- - [Inline configuration](#config-inline)
- [Include one association](#include_association)
- - [Scope](#include_association_scope)
- - [Options](#include_association_options)
- - [Multiple associations](#include_associations)
- [Exclude association](#exclude_association)
- - [Multiple associations](#exclude_associations)
- [Nullify attribute(s)](#nullify)
- [Execute finalize block](#finalize)
- [Traits](#traits)
- [Execution order](#execution_order)
- [ActiveRecord DSL](#ar_dsl)
- [Customization](#customization)

### <a name="configuration"></a>Configuration

You can configure the default adapter for cloners:

```ruby
# somewhere in initializers
Clowne.default_adapter = :active_record
```

#### <a name="config-inline"></a>Inline Configuration

You can also enhance the cloner configuration inline (i.e. add dynamic declarations):

```ruby
cloned = UserCloner.call(User.last) do
  exclude_association :profile

  finalize do |source, record|
    record.email = "clone_of_#{source.email}"
  end
end

cloned.email
# => "clone_of_john@example.com"

# associations:
cloned.posts.size == User.last.posts.size
# => true
cloned.profile
# => nil
```

Inline enhancement doesn't affect the _global_ configuration, so you can use it without any fear.

Thus it's also possible to clone objects without any cloner classes at all by using `Clowne::Cloner`:

```ruby
cloned = Clowne::Cloner.call(user) do
  # anything you want!
end
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

#### <a name="include_associations"></a>Include multiple association

It's possible to include multiple associations at once with default options and scope

```ruby
class User < ActiveRecord::Base
  has_many :accounts
  has_many :posts
end

class UserCloner < Clowne::Cloner
  adapter :active_record

  include_associations :accounts, :posts
end
```

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

**NOTE**: once excluded association cannot be re-included, e.g. the following cloner:

```ruby
class UserCloner < Clowne::Cloner
  exclude_association :comments

  trait :with_comments do
    # That wouldn't work
    include_association :comments
  end
end

clone = UserCloner.call(user, traits: :with_comments)
clone.comments.empty? #=> true
```

Why so? That allows to have deterministic cloning plans when combining multiple traits
(or inheriting cloners).

#### <a name="exclude_associations"></a>Exclude multiple association

It's possible to exclude multiple associations the same way as `include_associations` but with `exclude_associations`

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

### <a name="ar_dsl"></a>Active Record DSL

Clowne provides an optional ActiveRecord integration which allows you to configure cloners in your models and adds a shortcut to invoke cloners (`#clowne` method). (Note: that's exactly the way [`amoeba`](https://github.com/amoeba-rb/amoeba) works).

To enable this integration you must require `"clowne/adapters/active_record/dsl"` somewhere in your app, e.g. in initializer:

```ruby
# config/initializers/clowne.rb
require "clowne/adapters/active_record/dsl"
```

Now you can specify cloning configs in your AR models:

```ruby
class User < ActiveRecord::Base
  clowne_config do
    include_associations :profile

    nullify :email

    # whatever available for your cloners,
    # active_record adapter is set implicitly here
  end
end
```

And then you can clone objects like this:

```ruby
cloned_user = user.clowne(traits: my_traits, **params)
```

### <a name="customization"></a>Customization

Clowne is built with extensibility in mind. You can create your own DSL commands and resolvers.

Let's consider an example.

Suppose that you want to add `include_all` declaration to automagically include all associations (for ActiveRecord).

First, you should add a custom declaration:

```ruby
class IncludeAll # :nodoc: all
  def compile(plan)
    # Just add all_associations object to plan
    plan.set(:all_associations, self)
    # Plan supports 3 types of registers:
    #
    # 1) Scalar
    #
    # plan.set(key, value)
    # plan.remove(key)
    #
    # 2) Append-only lists
    #
    # plan.add(key, value)
    #
    # 3) Two-phase set (2P-Set) (see below)
    #
    # plan.add_to(type, key, value)
    # plan.remove_from(type, key)
  end
end

# Register our declrations, i.e. extend DSL
Clowne::Declarations.add :include_all, Clowne::Declarations::IncludeAll
```

\* Operations over [2P-Set](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#2P-Set_(Two-Phase_Set)) (adding/removing) do not depend on the order of execution; we use "remove-wins" semantics, i.e. when a key has been removed, it cannot be re-added.

Secondly, register a resolver:

```ruby
class AllAssociations
  # This method is called when all_associations command is applied.
  #
  #   source – source record
  #   record – target record (our clone)
  #   declaration – declaration object
  #   params – custom params passed to cloner
  def call(source, record, declaration, params:)
    source.class.reflections.each do |name, reflection|
      # Exclude belongs_to associations
      next if reflection.macro == :belongs_to
      # Resolve and apply association cloner
      cloner_class = Clowne::Adapters::ActiveRecord::Associations.cloner_for(reflection)
      cloner_class.new(reflection, source, declaration, params).call(record)
    end
    record
  end
end

# Finally, register the resolver
Clowne::Adapters::ActiveRecord.register_resolver(
  :all_associations, AllAssociations
)
```

Now you can use it likes this:

```ruby
class UserCloner < Clowne::Cloner
  adapter :active_record

  include_all
end
```

## Maintainers

- [Vladimir Dementyev](https://github.com/palkan)

- [Sverchkov Nikolay](https://github.com/ssnickolay)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

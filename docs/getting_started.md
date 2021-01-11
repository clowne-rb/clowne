# Getting Started

## Installation

To install Clowne with RubyGems:

```ruby
gem install clowne
```

Or add this line to your application's Gemfile:

```ruby
gem "clowne"
```

## Configuration

Basic cloner implementation looks like:

```ruby
class SomeCloner < Clowne::Cloner
  adapter :active_record # or adapter Clowne::Adapters::ActiveRecord
  # some implementation ...
end
```

You can configure the default adapter for cloners:

```ruby
# put to initializer
# e.g. config/initializers/clowne.rb
Clowne.default_adapter = :active_record
```

and skip explicit adapter declaration

```ruby
class SomeCloner < Clowne::Cloner
  # some implementation ...
end
```
See the list of [available adapters](supported_adapters.md).

## Basic Example

Assume that you have the following model:

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

class Profile < ActiveRecord::Base
  # create_table :profiles do |t|
  #   t.string :name
  # end
end

class Post < ActiveRecord::Base
  # create_table :posts
end
```

Let's declare our cloners first:

```ruby
class UserCloner < Clowne::Cloner
  adapter :active_record

  include_association :profile, clone_with: SpecialProfileCloner
  include_association :posts

  nullify :login

  # params here is an arbitrary Hash passed into cloner
  finalize do |_source, record, **params|
    record.email = params[:email]
  end
end

class SpecialProfileCloner < Clowne::Cloner
  adapter :active_record

  nullify :name
end
```

Now you can use `UserCloner` to clone existing records:

```ruby
user = User.last
# => <#User id: 1, login: 'clown', email: 'clown@circus.example.com'>

operation = UserCloner.call(user, email: "fake@example.com")
# => <#Clowne::Utils::Operation...>

operation.to_record
# => <#User id: nil, login: nil, email: 'fake@example.com'>

operation.persist!
# => true

cloned = operation.to_record
# => <#User id: 2, login: nil, email: 'fake@example.com'>

cloned.login
# => nil
cloned.email
# => "fake@example.com"

# associations:
cloned.posts.count == user.posts.count
# => true
cloned.profile.name
# => nil
```

## Overview

In [the basic example](#basic-example), you can see that Clowne consists of flexible DSL which is used in a class inherited of `Clowne::Cloner`.

You can combinate this DSL via [`traits`](traits.md) and make a cloning plan which exactly you want.

**We strongly recommend [`write tests`](testing.md) to cover resulting cloner logic**

Cloner class returns [`Operation`](operation.md) instance as a result of cloning. The operation provides methods to save cloned record. You can wrap this call to a transaction if it is necessary.

### Execution Order

The order of cloning actions depends on the adapter (i.e., could be customized).

All built-in adapters have the same order and what happens when you call `Operation#persist`:
- init clone (see [`init_as`](init_as.md)) (empty by default)
- [`clone associations`](include_association.md)
- [`nullify`](nullify.md) attributes
- run [`finalize`](finalize.md) blocks. _The order of [`finalize`](finalize.md) blocks is the order they've been written._
- run [`after_clone`](after_clone.md) callbacks
- __SAVE CLONED RECORD__
- run [`after_persist`](after_persist.md) callbacks

## Motivation & Alternatives

### Why did we decide to build our own cloning gem instead of using the existing solutions?

First, the existing solutions turned out not to be stable and flexible enough for us.

Secondly, they are Rails-only (or, more precisely, ActiveRecord-only).

Nevertheless, thanks to [amoeba](https://github.com/amoeba-rb/amoeba) and [deep_cloneable](https://github.com/moiristo/deep_cloneable) for inspiration.

For ActiveRecord we support amoeba-like [in-model configuration](active_record.md) and you can add missing DSL declarations yourself [easily](customization.md).

We also provide an ability to specify cloning [configuration in-place](inline_configuration.md) like `deep_clonable` does.

So, we took the best of these too and brought to the outside-of-Rails world.

### Why build a gem to clone models at all?

That's a good question. Of course, you can write plain old Ruby services do handle the cloning logic. But for complex models hierarchies, this approach has major disadvantages: high code complexity and lack of re-usability.

The things become even worse when you deal with STI models and different cloning contexts.

That's why we decided to build a specific cloning tool.

---
id: include_association
title: Include Association
---

Use this declaration to clone model's associations:

```ruby
class User < ActiveRecord::Base
  has_one :profile
end

class UserCloner < Clowne::Cloner
  include_association :profile
end
```

Looks pretty simple, right? But that's not all we may offer you! :)

The declaration supports additional arguments:

```ruby
include_association name, scope, options
```

## Scope

Scope can be a:
- `Symbol` - named scope.
- `Proc` - custom scope (supports parameters).

Example:

```ruby
class User < ActiveRecord::Base
  has_many :accounts
  has_many :posts
end

class Account < ActiveRecord::Base
  scope :active, -> { where(active: true) }
end

class Post < ActiveRecord::Base
  # t.string :status
end

class UserCloner < Clowne::Cloner
  include_association :accounts, :active
  include_association :posts, ->(params) { where(state: params[:state]) if params[:state] }
end

# Clone only draft posts
UserCloner.call(user, state: :draft)
# => <#User...
```

## Options

The following options are available:
- `:clone_with` - use custom cloner\*
- `:traits` - define special traits.

\* **NOTE:** the same cloner class would be used for **all children**

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

**NOTE**: if custom cloner is not defined, Clowne tries to infer the [implicit cloner](implicit_cloner.md).

## Nested parameters

Follow to [documentation page](parameters.md).

## Include multiple associations

You can include multiple associations at once too:

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

**NOTE:** in that case, it's not possible to provide custom scopes and options.

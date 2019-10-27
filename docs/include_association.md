# Include Association

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

### Supported Associations

Adapter                                   |1:1         |*:1         | 1:M         | M:M                     |
------------------------------------------|------------|------------|-------------|-------------------------|
[Active Record](active_record)  | has_one    | belongs_to | has_many    | has_and_belongs_to|
[Sequel](sequel)                | one_to_one | -          | one_to_many | many_to_many     |

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
  include_association :posts, ->(params) { where(state: params[:state]) }
end

# Clone only draft posts
UserCloner.call(user, state: :draft).to_record
# => <#User id: nil, ... >
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

UserCloner.call(user).to_record
# => <#User id: nil, ... >
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

### Belongs To association

You can include belongs_to association, but will do it carefully.
If you have loop by relations in your models, when you clone it will raise SystemStackError.
Check this [test](https://github.com/palkan/clowne/blob/master/spec/clowne/integrations/active_record_belongs_to_spec.rb) for instance.

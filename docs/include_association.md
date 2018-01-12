---
id: include_association
title: Include association
---

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

## Scope

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

## Options

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

## Include multiple association

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

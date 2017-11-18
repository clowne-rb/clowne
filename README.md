# Clowne

A flexible gem for cloning your models.

It is possible to use various adapters (currently only ActiveRecord is supported)

## Quick jump to DSL

- [Include All](#include_all)
- [Include Association](#include_association)
- [Exclude Association](#exclude_association)
- [Nullify](#nullify)
- [Finalize](#finalize)
- [Traits](#traits)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clowne'
```

## Usage

Configure your cloner

```ruby
class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  include_association :posts

  nullify :name

  finalize do |source, record, params|
    record.email = params[:email]
  end
end
```

and call it

```ruby
clone = UserCloner.call(User.last, { email: "fake@example.com" })
clone.persisted?
# => false
clone.save!
clone.posts.count == User.last.posts.count
# => true
clone.name
# => nil
clone.email
# => "fake@example.com"
```

## Configuration

### <a name="include_all"></a>Include All

If you need to clone all model associations just use `include_all` declaration.

```ruby
class User < ActiveRecord::Base
  has_one :profile
  has_many :posts
  ...
end

class UserCloner < Clowne::Cloner
  include_all
end
```

### <a name="include_association"></a>Include Association

Powerful declaration for including model's association.

```ruby
include_association name, scope, options
```

Scope can be a:

`Symbol` - named scope.

`Proc` - custom scope.

Options keys:

`:clone_with` - use custom cloner for all children

`:traits` - define special traits

Example:

```ruby
class Post < ActiveRecord::Base
  scope :active, -> where(active: true)
end

class User < ActiveRecord::Base
  has_many :posts
end
```

```ruby
class PostSpecialCloner < Clowne::Cloner
  trait :with_category do
    include_association :category
  end
end

class UserCloner < Clowne::Cloner
  include_association :posts
end

UserCloner.call(user)
# => <#User...
```

Example with custom scope:

```ruby
class UserCloner < Clowne::Cloner
  include_association :posts, ->(params) { where(status: params[:status] }
  # or
  # include_association :posts, :active - for using named scope
end

# posts will be cloned only with draft status
UserCloner.call(user, { status: :draft })
```

Example with custom cloner:

```ruby
class UserCloner < Clowne::Cloner
  include_association :posts, clone_with: PostSpecialCloner, trait: :with_category
end

# posts will be cloned with using PostSpecialCloner cloner
UserCloner.call(user)
```

**Notice: if custom cloner is not defined, clowne tries to find default cloner and use it. (PostCloner for previous example)**

### <a name="exclude_association"></a>Exclude Association

Exclude association from copying

```ruby
class UserCloner < Clowne::Cloner
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

### <a name="nullify"></a>Nullify

Nullify attributes (joins with another `nullify` declarations)

```ruby
class UserCloner < Clowne::Cloner
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

### <a name="finalize"></a>Finalize

Simple callback for changing record manually (joins with another `finalize` declarations)

```ruby
class UserCloner < Clowne::Cloner
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

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

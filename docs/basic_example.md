---
id: basic_example
title: Basic Example
---

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
  finalize do |_source, record, params|
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
# => <#User id: 1, login: 'clown', email: 'clown@circus.example.com' >

operation = UserCloner.call(user, email: 'fake@example.com')
# => <#Clowne::Utils::Operation...>

operation.to_record
# => <#User id: nil, login: nil, email: 'fake@example.com' >

operation.persist!
# => true

cloned = operation.to_record
# => <#User id: 2, login: nil, email: 'fake@example.com' >

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

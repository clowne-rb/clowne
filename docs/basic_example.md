---
id: basic_example
title: Basic Example
---

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

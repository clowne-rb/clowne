---
id: nullify
title: Nullify attributes
---

Nullify attributes of your record

```ruby
class User < ActiveRecord::Base
  # t.string :name
  # t.string :surname
  # t.string :email
end

class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  nullify :name, :email

  trait :nullify_surname do
    nullify :surname
  end
end

# nullify only name
clone = UserCloner.call(user)
clone.name.nil?
# => true
clone.email.nil?
# => true
clone.surname.nil?
# => false

# nullify name and surname
clone2 = UserCloner.call(user, traits: :nullify_surname)
clone.name.nil?
# => true
clone.surname.nil?
# => true
```

---
id: nullify
title: Nullify Attributes
sidebar_label: Nullify
---

To set a bunch of attributes to `nil` you can use the `nullify` declaration:

```ruby
class User < ActiveRecord::Base
  # t.string :name
  # t.string :surname
  # t.string :email
end

class UserCloner < Clowne::Cloner
  nullify :name, :email

  trait :nullify_surname do
    nullify :surname
  end
end

clone = UserCloner.call(user).to_record
clone.name.nil?
# => true
clone.email.nil?
# => true
clone.surname.nil?
# => false

clone2 = UserCloner.call(user, traits: :nullify_surname).to_record
clone2.name.nil?
# => true
clone2.surname.nil?
# => true
```

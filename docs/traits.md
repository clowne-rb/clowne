---
id: traits
title: Traits
---

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

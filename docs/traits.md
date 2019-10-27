# Traits

Traits allow you to group cloner declarations together and then apply them (like in [`factory_bot`](https://github.com/thoughtbot/factory_bot)):

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

UserCloner.call(user, traits: %i[with_posts with_profile nullify_name])
# or
UserCloner.call(user, traits: :nullify_name)
# or
# ...
```

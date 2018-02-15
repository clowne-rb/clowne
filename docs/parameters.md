---
id: parameters
title: Parameters
---

Clowne provides parameters for make your cloning logic more flexible. You can see their using in [`include_association`](include_association.md#scope) and [`finalize`](finalize.md) documentation pages.

Example:

```ruby
class UserCloner < Clowne::Cloner
  include_association :posts, ->(params) { where(state: params[:state]) }

  finalize do |_source, record, params|
    record.email = params[:email]
  end
end

cloned = UserCloner.call(user, state: :draft, email: 'cloned@example.com')
cloned.email
# => 'cloned@example.com'
```

## Potential Problems

Clowne is born as a part of our big project and we use it for cloning really deep object relations. When we started to use params and forwarding them between parent-child cloners we got a nasty bugs.

As result we strongly recommend to use ruby keyword arguments instead of params hash:

```ruby
# Bad
finalize do |_source, record, params|
  record.email = params[:email]
end

# Good
finalize do |_source, record, email:, **|
  record.email = email
end
```

## Nested Parameters

Also we implemented control over the parameters for cloning associations (you can read more [here](https://github.com/palkan/clowne/issues/15)).

Let's explain what the difference:

```ruby
class UserCloner < Clowne::Cloner
  trait :default do
    include_association :profile
    # equal to include_association :profile, params: false
  end

  trait :params_true do
    include_association :profile, params: true
  end

  trait :by_key do
    include_association :profile, params: :profile
  end

  trait :by_block do
    include_association :profile, params: lambda do |params|
      params[:profile].map { |k, v| [k, v.upcase] }.to_h
    end
  end
end

class ProfileCloner < Clowne::Cloner
  finalize do |_source, record, params|
    record.jsonb_field = params
  end
end

# Execute:

def get_profile_jsonb(user, trait)
  params = { profile: { name: 'John', surname: 'Cena' } }
  cloned = UserCloner.call(user, traits: trait, **params)
  cloned.profile.jsonb_field
end

get_profile_jsonb(user, :default)
# => {}

get_profile_jsonb(user, :params_true)
# => { profile: { name: 'John', surname: 'Cena' } }

get_profile_jsonb(user, :by_key)
# => { name: 'John', surname: 'Cena' }

get_profile_jsonb(user, :by_block)
# => { name: 'JOHN', surname: 'CENA' }
```

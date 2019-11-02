# Parameters

Clowne provides parameters for make your cloning logic more flexible. You can see their using in [`include_association`](include_association.md#scope) and [`finalize`](finalize.md) documentation pages.

Example:

```ruby
class UserCloner < Clowne::Cloner
  include_association :posts, ->(params) { where(state: params[:state]) }

  finalize do |_source, record, params|
    record.email = params[:email]
  end
end

operation = UserCloner.call(user, state: :draft, email: 'cloned@example.com')
cloned = operation.to_record
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

Also we implemented control over the parameters for cloning associations (you can read more [here](https://github.com/clowne-rb/clowne/issues/15)).

Let's explain what the difference:

```ruby
class UserCloner < Clowne::Cloner
  # Don't pass parameters to associations
  trait :default do
    include_association :profile
    # equal to include_association :profile, params: false
  end

  # Pass all parameters to associations
  trait :all_params do
    include_association :profile, params: true
  end

  # Filter parameters by key.
  # Notice: value by key must be a Hash.

  trait :by_key do
    include_association :profile, params: :profile
  end

  # Execute custom block with params as argument
  trait :by_block do
    include_association :profile, params: Proc.new do |params|
      params[:profile].map { |k, v| [k, v.upcase] }.to_h
    end
  end

  # Execute custom block with params and parent record as arguments
  trait :by_block_with_parent do
    include_association :profile, params: Proc.new do |params, user|
      {
        name: params[:profile][:name],
        email: user.email
      }
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
  cloned = UserCloner.call(user, traits: trait, **params).to_record
  cloned.profile.jsonb_field
end

get_profile_jsonb(user, :default)
# => {}

get_profile_jsonb(user, :all_params)
# => { profile: { name: 'John', surname: 'Cena' } }

get_profile_jsonb(user, :by_key)
# => { name: 'John', surname: 'Cena' }

get_profile_jsonb(user, :by_block)
# => { name: 'JOHN', surname: 'CENA' }

get_profile_jsonb(user, :by_block_with_parent)
# => { name: 'JOHN', email: user.email }
```

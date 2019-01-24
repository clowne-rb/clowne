---
id: from_v02_to_v10
title: From v0.2.x to v1.0.0
---

The breaking change of v1.0 is the return of a unified [`result object`](operation.md) for all adapters.

## ActiveRecord

### Update code to work with [`Operation`](operation.md)

```ruby
# Before
clone = UserCloner.call(user)
# => <#User id: nil, ...>
clone.save!
# => true

# After
operation = UserCloner.call(user)
# => <#Clowne::Utils::Operation ...>
operation.persist!
# => true
clone = operation.to_record
# => <#User id: 2, ...>
clone.persisted?
# => true
```

### Move post-processing cloning logic into [`after_persist`](after_persist.md) callback (if you have it)

<span style="display:none;"># rubocop:disable all</span>
```ruby
# Before
clone = UserCloner.call(user)
clone.save!
# do something with persisted clone

# After
class UserCloner < Clowne::Cloner
  # ...
  after_persist do |origin, clone, **|
    # do something with persisted clone
  end
end

clone = UserCloner.call(user).tap(&:persist).to_record
```
<span style="display:none;"># rubocop:enable all</span>

## Sequel

### Use `to_record` instead of `to_model`

```ruby
# Before
record_wrapper = UserCloner.call(user)
clone = record_wrapper.to_model
clone.new?
# => true

# After
operation = UserCloner.call(user)
clone = operation.to_record
clone.new?
# => true
```

### Use `operation#persist` instead of convering to model and calling `#save`

<span style="display:none;"># rubocop:disable all</span>
```ruby
# Before
record_wrapper = UserCloner.call(user)
clone = record_wrapper.to_model
clone.save

# After
clone = UserCloner.call(user).tap(&:persist).to_record
```
<span style="display:none;"># rubocop:enable all</span>

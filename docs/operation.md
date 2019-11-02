# Operation

Since version 1.0 Clowne has been returning specific result object instead of a raw cloned object. It has allowed unifying interface between adapters and has opened an opportunity to implement new features. We call this object `Operation`.

An instance of `Operation` has a very clear interface:

```ruby
class User < ActiveRecord::Base; end

class UserCloner < Clowne::Cloner
  nullify :email

  after_persist do |_origin, cloned, **|
    cloned.update_attributes(email: "evl-#{cloned.id}.ms")
  end
end

user = User.create(email: "evl.ms")
# => <#User id: 1, email: 'evl.ms', ...>

operation = UserCloner.call(user)

# Return resulted (non saved) object:
operation.to_record
# => <#User id: nil, email: nil, ...>

# Save cloned object and call after_persist callbacks:
operation.persist # or operation.persist!
# => true

operation.to_record
# => <#User id: 2, email: 'evl-2.ms', ...>

# Call only after_persist callbacks:
user2 = operation.to_record
# => <#User id: 2, email: 'evl-2.ms', ...>
user2.update_attributes(email: "admin@example.com")
# => <#User id: 2, email: 'admin@example.com' ...>
operation.run_after_persist
# => <#User id: 2, email: 'evl-2.ms', ...>
```

The last example is weird, but it can be helpful when you need to execute `save` (or `save!`) separately from `after_persist` callbacks:

```ruby
operation = UserClone.call(user)

# Wrap main cloning into the transaction
ActiveRecord::Base.transaction do
  operation.to_record.save!
end

# And after that execute after_persist without transaction
operation.run_after_persist
```

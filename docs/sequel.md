# Sequel

Under the hood, Clowne uses Sequel [`NestedAttributes` plugin](http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/NestedAttributes.html) for cloning source's associations, and you need to configure it.

Example:

```ruby
class UserCloner < Clowne::Cloner
  adapter :sequel

  include_association :account
end

class User < Sequel::Model
  # Configure NestedAttributes plugin
  plugin :nested_attributes

  one_to_one :account
  nested_attributes :account
end
```

and get cloned user

```ruby
user = User.last
operation = UserCloner.call(user)
# => <#Clowne::Adapters::Sequel::Operation...>
cloned = operation.to_record
# => <#User id: nil, ...>
cloned.new?
# => true
```

or you can save it immediately

```ruby
user = User.last
# => <#User id: 1, ...>
operation = UserCloner.call(user)
# => <#Clowne::Adapters::Sequel::Operation...>
operation.persist
# => true
cloned = operation.to_record
# => <#User id: 2, ...>
cloned.new?
# => false
```

If you try to clone association without `NestedAttributes` plugin, Clowne will skip this declaration.

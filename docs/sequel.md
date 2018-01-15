---
id: sequel
title: Sequel
---

Clowne uses Sequel [NestedAttributes plugin](http://sequel.jeremyevans.net/rdoc-plugins/classes/Sequel/Plugins/NestedAttributes.html) for cloning source's assocations and you need to configure it.

Also `Sequel` target record wrapped to special class for implementation full `Clowne`'s behaviour. You need to use method `to_model` for getting final cloned `Sequel::Model` object (or you can use `save` for saving cloned object to DB).

Example:

Configure nested attributes plugin

```ruby
class UserCloner < Clowne::Cloner
  adapter :sequel

  include_association :account
end

class User < Sequel::Model
  plugin :nested_attributes

  one_to_one :account
  nested_attributes :account
end
```

and get cloned user

```ruby
wrapper = UserCloner.call(User.last)
wrapper.class
# => Clowne::Adapters::Sequel::RecordWrapper
cloned_record = wrapper.to_model
cloned_record.class
# => User
cloned_record.new?
# => true
```

or you can save it immediately

```ruby
wrapper = UserCloner.call(User.last)
wrapper.class
# => Clowne::Adapters::Sequel::RecordWrapper
cloned_record = wrapper.save
cloned_record.class
# => User
cloned_record.new?
# => false
```

If you try to clone associations without NestedAttributes plugin Clowne will skip this declaration.

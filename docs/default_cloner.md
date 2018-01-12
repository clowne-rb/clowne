---
id: default_cloner
title: Default cloner
---

`clowne` tries to find default cloner and use it

```ruby
class User < ActiveRecord::Base
  has_one :profile
end

class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  include_association :profile
end

class ProfileCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  nullify :name
end

cloned = UserCloner.call(User.last)
cloned.profile.name
# => null
```

But you can use custom cloner (see [Include association](/clowne/docs/include_association.html))

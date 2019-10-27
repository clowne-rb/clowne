# Implicit Cloner

When [cloning associations](include_association.md) Clowne tries to infer an appropriate cloner class for the records (unless `clone_with` specified).

It relies on the naming convention: `MyModel` -> `MyModelCloner`.

Consider an example:

```ruby
class User < ActiveRecord::Base
  has_one :profile
end

class UserCloner < Clowne::Cloner
  include_association :profile
end

class ProfileCloner < Clowne::Cloner
  finalize do |source, record|
    record.name = "Clone of #{source.name}"
  end
end

user = User.last
user.profile.name
#=> "Bimbo"

cloned = UserCloner.call(user).to_record
cloned.profile.name
# => "Clone of Bimbo"
```

**NOTE:** when using [in-model cloner](active_record.md) for ActiveRecord it is used by default.

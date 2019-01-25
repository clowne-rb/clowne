---
id: init_as
title: Initialize Cloning Target
sidebar_label: Init As
---

You can override the default Clowne method which generates a _plain_ copy of a source object.
By default, Clowne initiates the cloned record using a `#dup` method.

For example, Cloners could be used not only to generate _fresh_ new models but to apply some transformations to the existing record:


```ruby
class User < ApplicationRecord
  has_one :profile
  has_many :posts
end

class UserCloner < Clowne::Cloner
  adapter :active_record

  include_association :profile

  trait :copy_settings do
    # Use a `target` for all the actions
    init_as { |_source, target:| target }
  end
end

jack = User.find_by(email: 'jack@evl.ms')
# => <#User id: 1, ...>
jack.create_profile(name: 'Jack')
# => <#Profile id: 1, name: 'Jack', ...>

john = User.find_by(email: 'john@evl.ms')
# => <#User id: 2, ...>

# we want to clone Jack's profile to John's user,
# without creating a new one
john_with_profile = UserCloner.call(jack, traits: :copy_settings, target: john).to_record
# => <#User id: 2, ...>
john_with_profile.profile
#=> <#Profile id: nil, name: 'Jack',...>
```

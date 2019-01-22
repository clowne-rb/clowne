---
id: active_record
title: Active Record
---

Clowne provides an optional ActiveRecord integration which allows you to configure cloners in your models and adds a shortcut to invoke cloners (`#clowne` method).

To enable this integration, you must require `"clowne/adapters/active_record/dsl"` somewhere in your app, e.g., in the initializer:

```ruby
# config/initializers/clowne.rb
require 'clowne/adapters/active_record/dsl'
Clowne.default_adapter = :active_record
```

Now you can specify cloning configs in your AR models:

```ruby
class User < ActiveRecord::Base
  clowne_config do
    include_associations :profile

    nullify :email

    # whatever available for your cloners,
    # active_record adapter is set implicitly here
  end
end
```

And then you can clone objects like this:

```ruby
user.clowne(traits: my_traits, **params).to_record
# => <#User id: nil...>
```

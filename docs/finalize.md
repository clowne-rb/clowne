---
id: finalize
title: Finalization
sidebar_label: Finalize
---

To apply custom transformations to the cloned record, you can use the `finalize` declaration:

```ruby
class UserCloner < Clowne::Cloner
  finalize do |_source, record, _params|
    record.name = 'This is copy!'
  end

  trait :change_email do
    finalize do |_source, record, params|
      record.email = params[:email]
    end
  end
end

cloned = UserCloner.call(user)
cloned.name
# => 'This is copy!'
cloned.email == 'clone@example.com'
# => false

cloned2 = UserCloner.call(user, traits: :change_email)
cloned2.name
# => 'This is copy!'
cloned2.email
# => 'clone@example.com'
```

Finalization blocks are called at the end of the [cloning process](execution_order.md).

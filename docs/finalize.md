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

clone = UserCloner.call(user)
clone.name
# => 'This is copy!'
clone.email == 'clone@example.com'
# => false

clone2 = UserCloner.call(user, traits: :change_email)
clone2.name
# => 'This is copy!'
clone2.email
# => 'clone@example.com'
```

Finalization blocks are called at the end of the [cloning process](execution_order.md).

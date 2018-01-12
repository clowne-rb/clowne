---
id: finalize
title: Execute finalize block
sidebar_label: Finalize block
---

Simple callback for changing record manually.

```ruby
class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  finalize do |_source, record, _params|
    record.name = 'This is copy!'
  end

  trait :change_email do
    finalize do |_source, record, params|
      record.email = params[:email]
    end
  end
end

# execute first finalize
clone = UserCloner.call(user)
clone.name
# => 'This is copy!'
clone.email == 'clone@example.com'
# => false

# execute both finalizes
clone2 = UserCloner.call(user, traits: :change_email)
clone2.name
# => 'This is copy!'
clone2.email
# => 'clone@example.com'

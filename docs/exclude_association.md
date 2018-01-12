---
id: exclude_association
title: Exclude association
---

Exclude association from copying

```ruby
class UserCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter

  include_association :posts

  trait :without_posts do
    exclude_association :posts
  end
end

# copy user and posts
clone = UserCloner.call(user)
clone.posts.count == user.posts.count
# => true

# copy only user
clone2 = UserCloner.call(user, traits: :without_posts)
clone2.posts
# => []
```

**NOTE**: once excluded association cannot be re-included, e.g. the following cloner:

```ruby
class UserCloner < Clowne::Cloner
  exclude_association :comments

  trait :with_comments do
    # That wouldn't work
    include_association :comments
  end
end

clone = UserCloner.call(user, traits: :with_comments)
clone.comments.empty? #=> true
```

Why so? That allows to have deterministic cloning plans when combining multiple traits
(or inheriting cloners).

## Exclude multiple association

It's possible to exclude multiple associations the same way as `include_associations` but with `exclude_associations`

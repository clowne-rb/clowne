# Exclude Association

Clowne doesn't include any association by default and doesn't provide _magic_ `include_all` declaration (although you can [add one by yourself](customization.md)).

Nevertheless, sometimes you might want to exclude already added associations (when inheriting a cloner or using [traits](traits.md)).

Consider an example:

```ruby
class UserCloner < Clowne::Cloner
  include_association :posts

  trait :without_posts do
    exclude_association :posts
  end
end

# copy user and posts
clone = UserCloner.call(user).to_record
clone.posts.count == user.posts.count
# => true

# copy only user
clone2 = UserCloner.call(user, traits: :without_posts).to_record
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

clone = UserCloner.call(user, traits: :with_comments).to_record
clone.comments.empty?
# => true
```

Why so? That allows us to have a deterministic cloning plan when combining multiple traits
(or inheriting cloners).

## Exclude multiple associations

It's possible to exclude multiple associations at once the same way as [`include_associations`](include_association.md):

```ruby
class UserCloner < Clowne::Cloner
  include_associations :accounts, :posts, :comments

  trait :without_posts do
    exclude_associations :posts, :comments
  end
end
```

# After Clone

The `after_clone` callbacks can help you to make additional operations on cloned record, like checking it with some business logic or actualizing cloned record attributes, before it will be saved to the database. Also it can help to avoid unneeded usage of [`after_persist`](after_persist) callbacks, and additional queries to database.

Examples:

```ruby
class User < ActiveRecord::Base
  # create_table :users do |t|
  #   t.string :login
  #   t.integer :draft_count
  # end

  has_many :posts # all user's posts
end

class Post < ActiveRecord::Base
  # create_table :posts do |t|
  #   t.integer :user_id
  #   t.boolean :is_draft
  # end

  scope :draft, -> { where is_draft: true }
end

class UserCloner < Clowne::Cloner
# clone user and his posts, which is drafts
  include_association :posts, scope: :draft

  after_clone do |_origin, clone, **|
    # actualize user attribute
    clone.draft_count = clone.posts.count
  end
end
```

`after_clone` runs when you call `Operation#to_record` or [`Operation#persist`](operation) (or `Operation#persist!`)

```ruby
# prepare data
user = User.create
3.times { Post.create(user: user, is_draft: false) }
2.times { Post.create(user: user, is_draft: true) }

operation = UserCloner.call(user)
# => <#Clowne::Utils::Operation ...>

clone = operation.to_record
# => <#User id: nil, draft_count: 2 ...>

clone.draft_count == user.posts.draft.count
# => true
```

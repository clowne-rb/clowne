# After Persist

*Notice: `after_persist` supported only with [`active_record`](active_record.md) adapter.*

The special mechanism for transformation of cloned record. In contradistinction to [`finalize`](finalize.md) executes with a saved record. This type of callbacks provides a default `mapper:` parameter which contains a relation between origin and cloned objects.

`after_persist` helps to restore broken _relationships_ while cloning associations and implement some logic with already persisted clone record. (_Inspired by [issues#19](https://github.com/palkan/clowne/issues/19)_)

Examples:

```ruby
class User < ActiveRecord::Base
  # create_table :users do |t|
  #   t.string :login
  #   t.integer :bio_id
  # end

  has_many :posts # all user's posts including BIO
  belongs_to :bio, class_name: "Post"
end

class Post < ActiveRecord::Base
  # create_table :posts do |t|
  #   t.integer :user_id
  # end
end

class UserCloner < Clowne::Cloner
  include_association :posts, params: true

  after_persist do |origin, clone, mapper:, **|
    cloned_bio = mapper.clone_of(origin.bio)
    clone.update(bio_id: cloned_bio.id)
  end
end

class PostCloner < Clowne::Cloner
  after_persist do |_, clone, run_job:, **|
    PostBackgroundJob.perform_async(clone.id) if run_job
  end
end
```

*Notice: See more about `mapper:` [`here`](clone_mapper.md).*

`after_persist` runs when you call [`Operation#persist`](operation) (or `Operation#persist!`)

```ruby
# prepare data
user = User.create
posts = Array.new(3) { Post.create(user: user) }
bio = posts.sample
user.update(bio_id: bio.id)

operation = UserCloner.call(user, run_job: true)
# => <#Clowne::Utils::Operation ...>

clone = operation.to_record
# => <#User id: nil, ...>

# we copy all user attributes including bio_id
# but this is wrong because bio refers to the source user's bio
# and we can fix it using after_persist when posts already saved
clone.bio_id == bio.id
# => true

# save clone and run after_persist callbacks
operation.persit

clone.bio_id == bio.id
# => false

clone.posts.pluck(:id).include?(clone.bio_id)
# => true
```

*Notice: be careful while using after_persist feature! If you clone a fat record (with a lot of associations) and will implement complex logic inside `after_persist` callback, it may affect your system.*

# Clone mapper

*Notice: `after_persist` supported only with [`active_record`](active_record.md) adapter.*

In [`after_persist`](after_persist.md) documenation you can find interisting code:

```ruby
class UserCloner < Clowne::Cloner
  # ...
  after_persist do |origin, clone, mapper:, **|
    cloned_bio = mapper.clone_of(origin.bio)
    clone.update_attributes(bio_id: cloned_bio.id)
  end
end
```

What is it `mapper:` and how it works?

`mapper:` is an instance of `Clowne::Utils::CloneMapper`. Active Record pattern gives us an opportunity to build our cloning tool on objects, so while cloning, we remember origin records and their clones and can use these relations after saving with `Clowne::Utils::CloneMapper`.

It perfectly works, and we can use the mapper to fix broken associations.
There is only one small nuance - we can get `#clone_of` only for the record that participated in a cloning process, and this limits the functionality of the `after_persist` callbacks.

But `Clowne is built with extensibility in mind™` and Clowne provides the ability to use your custom mapper:

```ruby
class CustomMapper < Clowne::Utils::CloneMapper
  def initialize(dependencies)
    super()
    # inject dependencies if need
    # or fetch it from other place (e.g. from DB)
    @default_bios = dependencies.index_by(&:title)
  end

  def clone_of(record)
    super(record) || fallback(record)
  end

  private

  def fallback(record)
    # put some mapping logic here
    return if record.is_a?(Post)

    @default_bios[record.title]
  end
end

# now we can use it:

class Post < ActiveRecord::Base
  # add simple scope
  # scope :default_bios, -> {...}
end

user = User.last
operation = UserCloner.call(user, mapper: CustomMapper.new(Post.default_bios))
operation.persist
```

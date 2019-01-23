[![Gem Version](https://badge.fury.io/rb/clowne.svg)](https://badge.fury.io/rb/clowne)
[![Build Status](https://travis-ci.org/palkan/clowne.svg?branch=master)](https://travis-ci.org/palkan/clowne)
[![Test Coverage](https://codeclimate.com/github/palkan/clowne/badges/coverage.svg)](https://codeclimate.com/github/palkan/clowne/coverage)
[![Docs](https://img.shields.io/badge/docs-link-brightgreen.svg)](https://clowne.evilmartians.io)

# Clowne

A flexible gem for cloning your models. Clowne focuses on ease of use and provides the ability to connect various ORM adapters.

📖 Read [Evil Martians Chronicles](https://evilmartians.com/chronicles/clowne-clone-ruby-models-with-a-smile) to learn about possible use cases.

📑 [Documentation](https://clowne.evilmartians.io)

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>


## Installation

To install Clowne with RubyGems:

```ruby
gem install clowne
```

Or add this line to your application's Gemfile:

```ruby
gem 'clowne'
```

## Quick Start

Assume that you have the following model:

```ruby
class User < ActiveRecord::Base
  # create_table :users do |t|
  #  t.string :login
  #  t.string :email
  #  t.timestamps null: false
  # end

  has_one :profile
  has_many :posts
end

class Profile < ActiveRecord::Base
  # create_table :profiles do |t|
  #   t.string :name
  # end
end

class Post < ActiveRecord::Base
  # create_table :posts
end
```

Let's declare our cloners first:

```ruby
class UserCloner < Clowne::Cloner
  adapter :active_record

  include_association :profile, clone_with: SpecialProfileCloner
  include_association :posts

  nullify :login

  # params here is an arbitrary Hash passed into cloner
  finalize do |_source, record, params|
    record.email = params[:email]
  end
end

class SpecialProfileCloner < Clowne::Cloner
  adapter :active_record

  nullify :name
end
```

Now you can use `UserCloner` to clone existing records:

```ruby
user = User.last
# => <#User id: 1, login: 'clown', email: 'clown@circus.example.com'>

operation = UserCloner.call(user, email: 'fake@example.com')
# => <#Clowne::Utils::Operation...>

operation.to_record
# => <#User id: nil, login: nil, email: 'fake@example.com'>

operation.persist!
# => true

cloned = operation.to_record
# => <#User id: 2, login: nil, email: 'fake@example.com'>

cloned.login
# => nil
cloned.email
# => "fake@example.com"

# associations:
cloned.posts.count == user.posts.count
# => true
cloned.profile.name
# => nil
```

Take a look at our [documentation](https://clowne.evilmartians.io) for more info!

### Supported ORM adapters

Adapter                                   |1:1         | 1:M         | M:M                     |
------------------------------------------|------------|-------------|-------------------------|
[Active Record](https://clowne.evilmartians.io/clowne/docs/active_record.html)  | has_one    | has_many    | has_and_belongs_to|
[Sequel](https://clowne.evilmartians.io/clowne/docs/sequel.html)                | one_to_one | one_to_many | many_to_many     |

## Maintainers

- [Vladimir Dementyev](https://github.com/palkan)

- [Sverchkov Nikolay](https://github.com/ssnickolay)

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

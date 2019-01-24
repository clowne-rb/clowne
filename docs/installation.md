---
id: installation
title: Installation & Configuration
---

## Installation

To install Clowne with RubyGems:

```ruby
gem install clowne
```

Or add this line to your application's Gemfile:

```ruby
gem 'clowne'
```

## Configuration

Basic cloner implementation looks like:

```ruby
class SomeCloner < Clowne::Cloner
  adapter :active_record # or adapter Clowne::Adapters::ActiveRecord
  # some implementation ...
end
```

You can configure the default adapter for cloners:

```ruby
# put to initializer
# e.g. config/initializers/clowne.rb
Clowne.default_adapter = :active_record
```

and skip explicit adapter declaration

```ruby
class SomeCloner < Clowne::Cloner
  # some implementation ...
end
```
See the list of [available adapters](supported_adapters.md).

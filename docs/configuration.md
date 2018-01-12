---
id: configuration
title: Configuration
---

Basic cloner implementation looks like

```ruby
class SomeCloner < Clowne::Cloner
  adapter Clowne::ActiveRecord::Adapter
  ...
end
```

But you can configure the default adapter for cloners:

```ruby
# somewhere in initializers
Clowne.default_adapter = :active_record
```

and skip adapter declaration

```ruby
class SomeCloner < Clowne::Cloner
  ...
end
```

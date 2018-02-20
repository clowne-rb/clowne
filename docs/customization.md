---
id: customization
title: Customization
---

Clowne is built with extensibility in mind. You can create your own DSL commands and resolvers.

Let's consider an example.

Suppose that you want to add the `include_all` declaration to automagically include all associations (for ActiveRecord).

First, you should add a custom declaration:

```ruby
# Extend from Base declaration
class IncludeAll < Clowne::Declarations::Base # :nodoc: all
  def compile(plan)
    # Just add all_associations declaration (self) to plan
    plan.set(:all_associations, self)
  end
end

# Register our declrations, i.e. extend DSL
Clowne::Declarations.add :include_all, Clowne::Declarations::IncludeAll
```

See more on `plan` in [architecture overview](architecture.md).

Secondly, register a resolver:

```ruby
class AllAssociations
  # This method is called when all_associations command is applied.
  #
  #   source – source record
  #   record – target record (our clone)
  #   declaration – declaration object
  #   params – custom params passed to cloner
  def call(source, record, declaration, params:)
    source.class.reflections.each_value do |_name, reflection|
      # Exclude belongs_to associations
      next if reflection.macro == :belongs_to
      # Resolve and apply association cloner
      cloner_class = Clowne::Adapters::ActiveRecord::Associations.cloner_for(reflection)
      cloner_class.new(reflection, source, declaration, params).call(record)
    end
    record
  end
end

# Finally, register the resolver
Clowne::Adapters::ActiveRecord.register_resolver(
  :all_associations, AllAssociations
)
```

Now you can use it likes this:

```ruby
class UserCloner < Clowne::Cloner
  adapter :active_record

  include_all
end
```

---
id: customization
title: Customization
---

Clowne is built with extensibility in mind. You can create your own DSL commands and resolvers.

Let's consider an example.

Suppose that you want to add `include_all` declaration to automagically include all associations (for ActiveRecord).

First, you should add a custom declaration:

```ruby
class IncludeAll # :nodoc: all
  def compile(plan)
    # Just add all_associations object to plan
    plan.set(:all_associations, self)
    # Plan supports 3 types of registers:
    #
    # 1) Scalar
    #
    # plan.set(key, value)
    # plan.remove(key)
    #
    # 2) Append-only lists
    #
    # plan.add(key, value)
    #
    # 3) Two-phase set (2P-Set) (see below)
    #
    # plan.add_to(type, key, value)
    # plan.remove_from(type, key)
  end
end

# Register our declrations, i.e. extend DSL
Clowne::Declarations.add :include_all, Clowne::Declarations::IncludeAll
```

\* Operations over [2P-Set](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#2P-Set_(Two-Phase_Set)) (adding/removing) do not depend on the order of execution; we use "remove-wins" semantics, i.e. when a key has been removed, it cannot be re-added.

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
    source.class.reflections.each do |name, reflection|
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

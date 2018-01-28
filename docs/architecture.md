---
id: architecture
title: Architecture
---

This post aims to help developers and contributors to understand how Clowne works under the hood.

There are two main notions we want to talk about: **declaration set** and **cloning plan**.

## Declaration set

_Declaration set_ is a result of calling Clowne DSL methods in the cloner class. There is (almost) one-to-one correspondence between configuration calls and declarations.

Consider an example:

```ruby
class UserCloner < Clowne::Cloner
  include_association :profile
  include_association :posts

  nullify :external_id, :slug

  trait :with_social_profile do
    include_association :social_profiles
  end
end
```

This cloner's declaration set contains 3 declarations. You can access it through `.declarations` method:

```ruby
UserCloner.declarations #=>
# [
#   <#Clowne::Declarations::IncludeAssociation...>,
#   <#Clowne::Declarations::IncludeAssociation...>,
#   <#Clowne::Declarations::Nullify...>
# ]
```

**NOTE:** `include_associations` and `exclude_associations` methods are just syntactic sugar, so they produce multiple declarations.

Traits are not included in the declaration set. Moreover, each trait is just a wrapper over a declaration set. You can access traits through `.traits` method:

```ruby
UserCloner.traits #=>
# {
#   with_social_profiles: <#Clowne::Declarations::Trait...>
# }

UserCloner.traits[:with_social_profiles].declarations #=>
# [
#   <#Clowne::Declarations::IncludeAssociation...>
# ]
```

## Cloning plan

Every time you use a cloner the corresponding declaration set (which is the cloner itself declarations combined with all the specified traits declaration sets) is compiled into a _cloning plan_.

The process is straightforward: starting with an empty `Plan`, we're applying every declaration to it.
Every declaration object must implement `#compile(plan)` method, which populates the plan with _actions_. For example:

```ruby
class IncludeAssociation
  def compile(plan)
    # add a `name` key with the specified value (self)
    # to :association set
    plan.add_to(:association, name, self)
  end
end
```

`Plan` supports 3 types of registers:

1) Scalars:

```ruby
plan.set(key, value)
plan.remove(key)
```

Used by [`init_as`](init_as.md) declaration.

2) Append-only lists:

```ruby
plan.add(key, value)
```

Used by [`nullify`](nullify.md) and [`finalize`](finalize.md) declarations.

3) Two-phase set (2P-Set\*):

```ruby
plan.add_to(type, key, value)
plan.remove_from(type, key)
```

Used by [`include_association`](include_association.md) and [`exclude_association`](exclude_association.md).


\* Operations over [2P-Set](https://en.wikipedia.org/wiki/Conflict-free_replicated_data_type#2P-Set_(Two-Phase_Set)) (adding/removing) do not depend on the order of execution; we use "remove-wins" semantics, i.e., when a key has been removed, it cannot be re-added.

Thus, the resulting plan is just a key-value storage.

## Plan resolving

The final step in the cloning process is to apply the compiled plan to a record.

Every adapter registers its own resolvers for each plan _key_ (or _action_). The [order of execution](execution_order.md) is also specified by the adapter.

For example, you can override `:nullify` resolver to handle associations:

```ruby
module NullifyWithAssociation
  def self.call(source, record, declaration, _params)
    reflection = source.class.reflections[declaration.name.to_s]

    # fallback to built-in nullify
    if reflection.nil?
      Clowne::Adapters::Base::Nullify.call(source, record, declaration)
    else
      association = record.__send__(declaration.name)
      next record if association.nil?

      association.is_a?(ActiveRecord::Relation) ? association.destroy_all : association.destroy
      record.association(declaration.name).reset

      # resolver must return cloned record
      record
    end
  end
end

Clowne::Adapters::ActiveRecord.register_resolver(
  :nullify,
  NullifyWithAssociation,
  # specify the order of execution (available options are `prepend`, `before`, `after`)
  before: :finalize
)
```

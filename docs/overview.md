---
id: overview
title: Overview
---

In [the basic example](basic_example.md), you can see that Clowne consists of flexible DSL which is used in a class inherited of `Clowne::Cloner`.

You can combinate this DSL via [`traits`](traits.md) and make a cloning plan which exactly you want.

**We strongly recommend [`write tests`](testing.md) to cover resulting cloner logic**

Cloner class returns [`Operation`](operation.md) instance as a result of cloning. The operation provides methods to save cloned record. You can wrap this call to a transaction if it is necessary.

## Execution Order

The order of cloning actions depends on the adapter (i.e., could be customized).

All built-in adapters have the same order and what happens when you call `Operation#persist`:
- init clone (see [`init_as`](init_as.md)) (empty by default)
- [`clone associations`](include_association.md)
- [`nullify`](nullify.md) attributes
- run [`finalize`](finalize.md) blocks. _The order of [`finalize`](finalize.md) blocks is the order they've been written._
- __SAVE CLONED RECORD__
- run [`after_persist`](after_persist.md) callbacks

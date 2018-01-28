---
id: execution_order
title: Execution Order
---

The order of cloning actions depends on the adapter (i.e., could be customized).

All built-in adapters have the same order:
- init clone (see [`init_as`](init_as.md))
- clone associations
- nullify attributes
- run [`finalize`](finalize.md) blocks

The order of [`finalize`](finalize.md) blocks is the order they've been written.

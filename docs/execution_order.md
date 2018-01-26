---
id: execution_order
title: Execution order
---

The order of cloning actions depends on the adapter (i.e. could be customized).

All built-in adapters has the same order:
- init clone (see [`init_as`](init_as.md))
- clone associations
- nullify attributes
- run [`finalize`](finalize.md) blocks

The order of `finalize` blocks is the order they've been written.

---
id: execution_order
title: Execution order
---

The order of cloning actions depends on the adapter.

For ActiveRecord:
- clone associations
- nullify attributes
- run `finalize` blocks
The order of `finalize` blocks is the order they've been written.

---
id: alternatives
title: Motivation & Alternatives
---

### Why did we decide to build our own cloning gem instead of using the existing solutions?

First, the existing solutions turned out not to be stable and flexible enough for us.

Secondly, they are Rails-only (or, more precisely, ActiveRecord-only).

Nevertheless, thanks to [amoeba](https://github.com/amoeba-rb/amoeba) and [deep_cloneable](https://github.com/moiristo/deep_cloneable) for inspiration.

For ActiveRecord we support amoeba-like [in-model configuration](active_record.md) and you can add missing DSL declarations yourself [easily](customization.md).

We also provide an ability to specify cloning [configuration in-place](inline_configuration.md) like `deep_clonable` does.

So, we took the best of these too and brought to the outside-of-Rails world.

### Why build a gem to clone models at all?

That's a good question. Of course, you can write plain old Ruby services do handle the cloning logic. But for complex models hierarchies, this approach has major disadvantages: high code complexity and lack of re-usability.

The things become even worse when you deal with STI models and different cloning contexts.

That's why we decided to build a specific cloning tool.

# Change log

## 1.0.0 (2019-02-01)

- Return `Operation` instance as a rusult of cloning. ([@ssnickolay][])

See [migration guide](https://clowne.evilmartians.io/docs/from_v02_to_v10.html)

- Add `after_persist` declaration. ([@ssnickolay][], [@palkan][])

- Unify interface between adapters. ([@ssnickolay][])

- Deprecate `Operation#save` and `Operation#save!` methods. ([@ssnickolay][])

- Improve Docs ([@ssnickolay][], [@palkan][])

## 0.2.0 (2018-02-21)

- Add `Cloner#partial_apply` method. ([@palkan][])

- Add RSpec matchers `clone_association` / `clone_associations`. ([@palkan][])

- [[#15](https://github.com/palkan/clowne/issues/15)] Add control over nested params. ([@ssnickolay][])

## 0.1.0 (2018-02-01)

- Add `init_as` declaration. ([@palkan][])

- Support [Sequel](https://github.com/jeremyevans/sequel). ([@ssnickolay][])

- Support passing a block to `#clowne` for inline configuration. ([@palkan][])

## 0.1.0.beta1 (2018-01-08)

- Initial version. ([@ssnickolay][], [@palkan][])

[@palkan]: https://github.com/palkan
[@ssnickolay]: https://github.com/ssnickolay

# Change Log
All notable changes to this project will be documented in this file.

---

## [0.6.0](https://github.com/nazeehshoura/RxState/releases/tag/0.6.0)

* Uses RxSwift 5.1.1
* Uses RxCocoa 5.1.1
* Supports Swift 5
* The state now is a `BehaviorRelay`, replacing the depricated `Variable`
* Fixes Bug #15
* Has updatets for RxStateExample for latest changes

## [0.5.0](https://github.com/nazeehshoura/RxState/releases/tag/0.5.0)

* Uses RxSwift 3.5.0
* Uses RxCocoa 3.5.0
* Renames `action` to `lastDispatchedaAtion`.
* Renames `action` to `lastDispatchedaAtion`.
* Defines `StoreState` as a type alias for `[SubstateType]`

## [0.3.0](https://github.com/nazeehshoura/RxState/releases/tag/0.3.0)

* Replaces `observe(Driver<CurrentStateLastAction>)` with `observe(StoreType)` in `MiddlewareType`.

## [0.2.1](https://github.com/nazeehshoura/RxState/releases/tag/0.2.1)

* Renames `Middleware` to `MiddlewareType`.

** *Unreleased* **:
- fix: `displayed` and `rxVisible` now do not assume UIViewController starts not visible

** Version 2.13.0 **:

- fix: use xcframeworks for RxFlow/RxFlowDemo deps to please Carthage
- fix: adapt method is disposed before being completed

** Version 2.12.4 **:

- fix reentrancy issue with forwardToCurrentFlow

** Version 2.12.3 **:

- fix "Unhandled files" warnings in the Package.swift file
- fix re-entrancy issue in the FlowCoordinator file
- revert to a strong retain policy in the Reactive+UIViewController file (see version 2.12.0)

** Version 2.12.2 **:

- ensure the navigate function is called on the main thread (regression introduced in 2.12.1)

** Version 2.12.1 **:

- fix a possible memory leak when the Coordinator's lifecycle was unexpectedly longer than the flow ones (thanks to @asiliuk)

** Version 2.12.0 **:

- bump to RxSwift 6.0.0
- change retain policy in Reactive+UIViewController.swift

** Version 2.10 **:

- remove Reusable as a private dependency
- update to Swift 5.3

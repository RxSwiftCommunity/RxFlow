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

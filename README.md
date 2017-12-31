\| <img alt="RxFlow Logo" src="https://raw.githubusercontent.com/RxSwiftCommunity/RxFlow/develop/Resources/RxFlow_logo.png" width="200"/> | <ul align="left"><li><a href="#about">About</a><li><a href="#navigation-concerns">Navigation concerns</a><li><a href="#rxflow-aims-to">RxFlow aims to</a><li><a href="#installation">Installation</a><li><a href="#the-core-principles">The core principles</a><li><a href="#how-to-use-rxflow">How to use RxFlow</a><li><a href="#tools-and-dependencies">Tools and dependencies</a></ul> |
| -------------- | -------------- |
| Travis CI | [![Build Status](https://travis-ci.org/twittemb/RxFlow.svg?branch=develop)](https://travis-ci.org/twittemb/RxFlow) |
| Frameworks | [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |
| Platform | [![Platform](https://img.shields.io/cocoapods/p/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |
| Licence | [![License](https://img.shields.io/cocoapods/l/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |

<span style="float:none" />

# About
RxFlow is a navigation framework for iOS applications based on a Flow Coordinator pattern

This README is a short story of the whole conception process that led me to this framework.

Take a look at this wiki page to learn more about RxFlow: [RxFlow in details](https://github.com/RxSwiftCommunity/RxFlow/wiki/RxFlow-in-details)

For a really detailed explanation, take a look at my blog:
- RxFlow Part 1 ([The theory](https://twittemb.github.io/swift/coordinator/reactive/rxswift/2017/11/08/rxflow-part-1/))
- RxFlow Part 2 ([In practice](https://twittemb.github.io/swift/coordinator/reactive/rxswift/2017/12/09/rxflow-part-2/))
- RxFlow Part 3 ([Tips and Tricks](https://twittemb.github.io/swift/coordinator/reactive/rxswift/2017/12/22/rxflow-part-3-tips-and-tricks/))

# Navigation concerns
Regarding navigation within an iOS application, two choices are available:
- Use the builtin mechanism provided by Apple and Xcode: storyboards and segues
- Implement a custom mechanism directly in the code

The disadvantage of these two solutions:
- Builtin mechanism: navigation is relatively static and the storyboards are massive. The navigation code pollutes the UIViewControllers
- Custom mechanism: code can be difficult to set up and can be complex depending on the chosen design pattern (Router, Coordinator)

# RxFlow aims to
- Promote the cutting of storyboards into atomic units to enable collaboration and reusability of UIViewControllers
- Allow the presentation of a UIViewController in different ways according to the navigation context
- Ease the implementation of dependency injection
- Remove every navigation mechanism from UIViewControllers 
- Promote reactive programing
- Express the navigation in a declarative way while addressing the majority of the navigation cases
- Facilitate the cutting of an application into logical blocks of navigation

# Installation

## Carthage

In your Cartfile:

```ruby
github "RxSwiftCommunity/RxFlow"

```

## CocoaPods

In your Podfile:

```ruby
pod 'RxFlow'

```

# The core principles

This is how I imagine the Flow Coordinator pattern in a simple application:

<p align="center">
<img src="https://raw.githubusercontent.com/RxSwiftCommunity/RxFlow/develop/Resources/RxFlow_Coordinate.png" width="480"/>
</p>

How do I read this ?

- Here we have three **Flows**: **Application**, **Onboarding** and **Settings** which describe the three main navigation sections of the application.
- We also have three **Steps**: **Dashboard** (the default navigation state triggered at the application bootstrap), **Set the server** and **Login**.

Each one of these **Steps** will be triggered either because of user actions or because of backend state changes.
The crossing between a **Flow** and a **Step** represented by a colored chip will be a specific navigation action (such as a UIViewController popup).
It will be up to the **Coordinator** engine to trigger the "navigate(to:)" function on the appropriate **Flow**.

## Flow, Step and Flowable
Combinaisons of **Flows** and **Steps** describe all the possible navigation actions within your application.
Each **Flow** defines a clear navigation area (that makes your application divided in well defined parts) in which every **Step** will lead to a specific navigation action (push a VC on a stack, pop up a VC, ...).

In the end, the **Flow.navigate(to:)** function has to return an array of **Flowable**.

A **Flowable** tells the **Coordinator** engine "The next thing that can produce new **Steps** in your Reactive mechanism are":
- this particular next **Presentable**
- this particular next **Stepper**

In some cases, the **navigate(to:)** function can return an empty array of **Flowable** because we know there won't be any further navigation after the one we are doing.

For the record, the Demo application shows pretty much every possible cases. 

## Presentable
Presentable is an abstraction of something that can be presented.
Because a **Step** cannot be emitted unless its associated **Presentable** is displayed,
**Presentable** offers Reactive observables that the **Coordinator** will subscribe to (so it will be aware of the presentation state of the **Presentable**).
Therefore there is no risk of firing a new **Step** while its **Presentable** is not yet fully displayed.

## Stepper
A **Stepper** can be anything: a custom UIViewController, a ViewModel, a Presenter…
Once it is registered in the **Coordinator** engine, a **Stepper** can emits new **Steps** via its “steps” property (which is a Rx BehavorSubject).
The **Coordinator** will listen for these **Steps** and call the **Flow**’s “navigate(to:)” function.

A **Step** can even embed inner values (such as Ids, URLs, ...) that will be propagated to screens presented by the **Flows**.

## Coordinator
A **Coordinator** is a just a tool for the developper. Once he has defined the suitable combinations of **Flows** and **Steps** representing the navigation possibilities, the job of the **Coordinator** is to weave these combinaisons into patterns, according to navigation **Steps** changes induced by **Steppers**. 

It is up to the developper to:
- define the **Flows** that represent in the best possible way its application sections (such as Dashboard, Onboarding, Settings, ...) in which significant navigation actions are needed
- provide the **Steppers** that will trigger the **Coordinator**  process.

# How to use RxFlow

## Code samples

### How to declare **Steps**

As **Steps** are seen like some states spread across the application, it seems pretty obvious to use an enum to declare them

```swift
enum DemoStep: Step {
    case apiKey
    case apiKeyIsComplete

    case movieList

    case moviePicked (withMovieId: Int)
    case castPicked (withCastId: Int)

    case settings
    case settingsDone
    case about
}
```

### How to declare a **Flow**

The following **Flow** is used as a Navigation stack.

```swift
class WatchedFlow: Flow {

    var root: UIViewController {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let service: MoviesService

    init(withService service: MoviesService) {
        self.service = service
    }

    func navigate(to step: Step) -> [Flowable] {

        guard let step = step as? DemoStep else { return Flowable.noFlow }

        switch step {

        case .movieList:
            return navigateToMovieListScreen()
        case .moviePicked(let movieId):
            return navigateToMovieDetailScreen(with: movieId)
        case .castPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        default:
            return Flowable.noFlow
        }

    }

    private func navigateToMovieListScreen () -> [Flowable] {
        let viewModel = WatchedViewModel(with: self.service)
        let viewController = WatchedViewController.instantiate(with: viewModel)
        viewController.title = "Watched"
        self.rootViewController.pushViewController(viewController, animated: true)
        return [Flowable(nextPresentable: viewController, nextStepper: viewModel)]
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> [Flowable] {
        let viewModel = MovieDetailViewModel(withService: self.service, andMovieId: movieId)
        let viewController = MovieDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
        return [Flowable(nextPresentable: viewController, nextStepper: viewModel)]
    }

    private func navigateToCastDetailScreen (with castId: Int) -> [Flowable] {
        let viewModel = CastDetailViewModel(withService: self.service, andCastId: castId)
        let viewController = CastDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return Flowable.noFlow
    }
}
```

### How to declare a **Stepper**

In theory a **Stepper**, as it is a protocol, can be anything (a UIViewController for instance) by I suggest to isolate that behavior in a ViewModel or so.
For simple cases (for instance when we only need to bootstrap a **Flow** with a first **Step** and don't want to code a basic **Stepper** for that), RxFlow provides a OneStepper class.

```swift
class WatchedViewModel: Stepper {

    let movies: [MovieViewModel]

    init(with service: MoviesService) {
        // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        self.movies = service.watchedMovies().map({ (movie) -> MovieViewModel in
            return MovieViewModel(id: movie.id, title: movie.title, image: movie.image)
        })
    }

    public func pick (movieId: Int) {
        self.steps.onNext(DemoStep.moviePicked(withMovieId: movieId))
    }

}
```

### How to bootstrap the RxFlow process

The coordination process is pretty straightfoward and happens in the AppDelegate.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    let disposeBag = DisposeBag()
    var window: UIWindow?
    var coordinator = Coordinator()
    let movieService = MoviesService()
    lazy var mainFlow = {
        return MainFlow(with: self.movieService)
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard let window = self.window else { return false }

        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print ("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        Flows.whenReady(flow: mainFlow, block: { [unowned window] (flowRoot) in
            window.rootViewController = flowRoot
        })

        coordinator.coordinate(flow: mainFlow, withStepper: OneStepper(withSingleStep: DemoStep.apiKey))

        return true
    }
}
```

As a bonus, the **Coordinator** offers a Rx extension that allows you to track the navigation actions (Coordinator.rx.willKnit and Coordinator.rx.didKnit).

## Demo Application
A demo application is provided to illustrate the core mechanisms. Pretty much every kind of navigation is addressed. The app consists of:
- a MainFlow that represents the main navigation section (a settings screen and then a dashboard composed of two screens in a tab bar controller)
- a WishlistFlow that represents a navigation stack of movies that you want to watch
- a WatchedFlow that represents a navigation stack of movies that you've already seen
- a SettingsFlow that represents the user's preferences in a master/detail presentation

<br/>
<kbd>
<img style="border:2px solid black" alt="Demo Application" src="https://raw.githubusercontent.com/RxSwiftCommunity/RxFlow/develop/Resources/RxFlow.gif"/>
</kbd>

# Tools and dependencies

RxFlow relies on:
- SwiftLint for static code analysis ([Github SwiftLint](https://github.com/realm/SwiftLint))
- RxSwift to expose Wefts into Observables the Loom can react to ([Github RxSwift](https://github.com/ReactiveX/RxSwift))
- Reusable in the Demo App to ease the storyboard cutting into atomic ViewControllers ([Github Reusable](https://github.com/AliSoftware/Reusable))

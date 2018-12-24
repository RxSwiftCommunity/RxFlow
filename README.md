| <img alt="RxFlow Logo" src="https://raw.githubusercontent.com/RxSwiftCommunity/RxFlow/develop/Resources/RxFlow_logo.png" width="250"/> | <ul align="left"><li><a href="#about">About</a><li><a href="#navigation-concerns">Navigation concerns</a><li><a href="#rxflow-aims-to">RxFlow aims to</a><li><a href="#installation">Installation</a><li><a href="#the-core-principles">The core principles</a><li><a href="#how-to-use-rxflow">How to use RxFlow</a><li><a href="#tools-and-dependencies">Tools and dependencies</a></ul> |
| -------------- | -------------- |
| Travis CI | [![Build Status](https://travis-ci.org/RxSwiftCommunity/RxFlow.svg?branch=develop)](https://travis-ci.org/RxSwiftCommunity/RxFlow) |
| Frameworks | [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |
| Platform | [![Platform](https://img.shields.io/cocoapods/p/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |
| Licence | [![License](https://img.shields.io/cocoapods/l/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |

<span style="float:none" />

# About
RxFlow is a navigation framework for iOS applications based on a **Reactive Flow Coordinator pattern**.

This README is a short story of the whole conception process that led me to this framework.

You will find a very detail explanation of the whole project on my blog:
- [RxFlow Part 1: In Theory](https://twittemb.github.io/swift/coordinator/rxswift/rxflow/reactive%20programming/2017/11/08/rxflow-part-1-in-theory/)
- [RxFlow Part 2: In Practice](https://twittemb.github.io/swift/coordinator/reactive/rxflow/reactive%20programming/2017/12/09/rxflow-part-2-in-practice/)
- [RxFlow Part 3: Tips and Tricks](https://twittemb.github.io/swift/coordinator/reactive/rxswift/reactive%20programming/rxflow/2017/12/22/rxflow-part-3-tips-and-tricks/)

The Jazzy documentation can be seen here as well: [Documentation](http://community.rxswift.org/RxFlow/)

# Migrating from v1.x.x to v2.0.0
Here are the changes you should be aware of to use RxFlow 2.0.0 when coming from a previous version:
- **Coordinator** has been renamed in **FlowCoordinator**.
- **NextFlowItem** and **NextFlowItems** have been renamed in **FlowContributor** and **FlowContributors**.
- The FlowContributors enum entry **.triggerParentFlow(withStep: Step)** has been renamed **contributeToParentFlow (withStep: Step)**.
- The FlowContributors enum entry **.end (withStepForParentFlow: Step)** has been renamed in **.end (contributingToParentFlowWithStep: Step)**.
- A new entry has been added to the FlowContributors enum: **.contributeToCurrentFlow (withStep: Step)**. It allows to forward a new Step in the same Flow.
- In an effort to minimize the usage of **objc_get/setAssociatedObject**, you have to declare a **steps property as a PublishSubject<Step>** by yourself in each custom **Stepper** you define.
- To trigger an initial **Step** inside a **Stepper** you now have to implement an **initialStep** computed property. A default implementation is provided by RxFlow if it makes no sense to emit a first Step for your specific use case. This default implementation emits a "void step" that will be ignored by the **FlowCoordinator**.
- The reactive **step** property of a **Stepper** has been renamed in **steps** to reflect the sequence of steps it can emit.
- **FlowCoordinator** has been totally rewritten to improve memory management.
- **HasDisposeBag** has been removed from the project as it was not mandatory in the implementation and is not truely related to RxFlow. A similar implementation can be found in [NSObject-Rx](https://github.com/RxSwiftCommunity/NSObject-Rx)
- The **RxFlowStep** enum is now provided to offer some common steps that can be used in lots of applications. This enum will grow in size over time.
- Old names are still usable but have been explicitly deprecated.

The DemoApp has been updated to implement those changes.

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
- Promote reactive programming
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

# The key principles

The **Coordinator** pattern is a great way to organize the navigation within your application. It allows to:
- remove the navigation code from UIViewControllers
- reuse UIViewControllers in different navigation contexts
- ease the use of dependency injection

To learn more about it, I suggest you take a look at this article: ([Coordinator Redux](http://khanlou.com/2015/10/coordinators-redux/)).

The Coordinator pattern can have some drawbacks:
- the coordination mechanism has to be written each time you bootstrap an application
- communicating with the Coordinators stack can lead to a lot of boilerplate code.

RxFlow is a reactive implementation of the Coordinator pattern. It has all the great features of this architecture, but brings some improvements:
- it makes the navigation more declarative within **Flows**
- it provides a built-in **FlowCoordinator** that handles the navigation between **Flows**
- it uses reactive programming to trigger navigation actions towards the **FlowCoordinators**

There are 6 terms you have to be familiar with to understand **RxFlow**:
- **Flow**: each **Flow** defines a navigation area in your application. This is the place where you declare the navigation actions (such as presenting a UIViewController or another Flow).
- **Step**: each **Step** is a navigation state inside a **Flow**. Combinations of **Flows** and **Steps** describe all the possible navigation actions of your application. A **Step** can even embed inner values (such as Ids, URLs, ...) that will be propagated to screens declared in the **Flows**.
- **Stepper**: a **Stepper** can be anything that emits **Steps** inside **Flows**.
- **Presentable**: it is an abstraction of something that can be presented (basically **UIViewController** and **Flow** are **Presentable**).
- **FlowContributor**: it is a simple data structure that combines a **Presentable** and a **Stepper**. It tells the **FlowCoordinator** what will be the next things that can emit new **Steps** in a **Flow**.
- **FlowCoordinator**: once the developer has defined the suitable combinations of **Flows** and **Steps** representing the navigation possibilities, the job of the **FlowCoordinator** is to mix these combinations to handle all the navigation of your app.

# How to use RxFlow

## Code samples

### How to declare **Steps**

As **Steps** are seen like some navigation states spread across the application, it seems pretty obvious to use an enum to declare them:

```swift
enum DemoStep: Step {
    case movieList
    case moviePicked (withMovieId: Int)
    case castPicked (withCastId: Int)

    case settings
    case settingsDone
    case about
}
```

### How to declare a **Flow**

The following **Flow** is used as a Navigation stack. All you have to do is:
- declare a root **Presentable** on which your navigation will be based.
- implement the **navigate(to:)** function to transform a **Step** into a navigation actions.

The **navigate(to:)** function returns a **FlowContributors**. This is how the next navigation actions will be produced (the **Stepper** defined in a **FlowContributor** will emit the next **Steps**)

```swift
class WatchedFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UINavigationController()
    private let service: MoviesService

    init(withService service: MoviesService) {
        self.service = service
    }

    func navigate(to step: Step) -> FlowContributors {

        guard let step = step as? DemoStep else { return .none }

        switch step {

        case .movieList:
            return navigateToMovieListScreen()
        case .moviePicked(let movieId):
            return navigateToMovieDetailScreen(with: movieId)
        case .castPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        default:
            return .none
    	}
    }

    private func navigateToMovieListScreen () -> FlowContributors {
        let viewModel = WatchedViewModel(with: self.service)
        let viewController = WatchedViewController.instantiate(with: viewModel)
        viewController.title = "Watched"
        self.rootViewController.pushViewController(viewController, animated: true)
	return .one(flowItem: FlowContributor(nextPresentable: viewController, nextStepper: viewModel))
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> FlowContributors {
        let viewModel = MovieDetailViewModel(withService: self.service, andMovieId: movieId)
        let viewController = MovieDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
	return .one(flowItem: FlowContributor(nextPresentable: viewController, nextStepper: viewModel))
    }

    private func navigateToCastDetailScreen (with castId: Int) -> FlowContributors {
        let viewModel = CastDetailViewModel(withService: self.service, andCastId: castId)
        let viewController = CastDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return .none
    }
}
```

### How to declare a **Stepper**

In theory a **Stepper**, as it is a protocol, can be anything (a UIViewController for instance) by I suggest to isolate that behavior in a ViewModel or something similar.
For simple cases (for instance when we only need to bootstrap a **Flow** with a first **Step** and don't want to code a basic **Stepper** for that), RxFlow provides a **OneStepper** class.

```swift
class WatchedViewModel: Stepper {

    let movies: [MovieViewModel]
    let steps = PublishRelay<Step>()

    init(with service: MoviesService) {
        // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        self.movies = service.watchedMovies().map({ (movie) -> MovieViewModel in
            return MovieViewModel(id: movie.id, title: movie.title, image: movie.image)
        })
    }

    // when a movie is picked, a new Step is emitted.
    // That will trigger a navigation action within the WatchedFlow
    public func pick (movieId: Int) {
        self.steps.accept(DemoStep.moviePicked(withMovieId: movieId))
    }

}
```

### Is it possible to coordinate multiple Flows ?

Of course, it is the aim of a Coordinator. As a Flow is a Presentable, a Flow can present other Flows.

For instance, from the WishlistFlow, we launch the SettingsFlow in a popup.

```swift
private func navigateToSettings () -> FlowContributors {     
    let settingsStepper = SettingsStepper()
    let settingsFlow = SettingsFlow(withService: self.service)
    Flows.whenReady(flow1: settingsFlow, block: { [weak self] (root: UISplitViewController) in
        self?.rootViewController.present(root, animated: true)
    })
    return .one(flowItem: FlowContributor(nextPresentable: settingsFlow, nextStepper: OneStepper(withSingleStep: DemoStep.settings)))
}
```

For a more complex case, see the **DashboardFlow.swift** and the **SettingsFlow.swift** files in which we handle a UITabBarController and a UISplitViewController.

### How to bootstrap the RxFlow process

The coordination process is pretty straightfoward and happens in the AppDelegate.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    let disposeBag = DisposeBag()
    var window: UIWindow?
    var coordinator = FlowCoordinator()
    let appServices = AppServices()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard let window = self.window else { return false }

        // listening for Coordinator mechanism is not mandatory, but useful
        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print ("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        let appFlow = AppFlow(withWindow: window, andServices: self.appServices)
        self.coordinator.coordinate(flow: self.appFlow, with: AppStepper(withServices: self.appServices))

        return true
    }
}
```

As a bonus, **FlowCoordinator** offers a Rx extension that allows you to track the navigation actions (FlowCoordinator.rx.willNavigate and FlowCoordinator.rx.didNavigate).

## Demo Application
A demo application is provided to illustrate the core mechanisms. Pretty much every kind of navigation is addressed. The app consists of:
- an AppFlow that represents the main navigation. This Flow will handle the OnboardingFlow and the DashboardFlow
- an OnBoardingFlow that represents a 2 steps onboarding wizard in a UINavigationController. It will only be displayed the first time the app is used
- a DashboardFlow that handles the Tabbar for the WishlistFlow and the WatchedFlow
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
- RxSwift to expose Steps as Observables the Coordinator can react to ([Github RxSwift](https://github.com/ReactiveX/RxSwift))
- Reusable in the Demo App to ease the storyboard cutting into atomic ViewControllers ([Github Reusable](https://github.com/AliSoftware/Reusable))


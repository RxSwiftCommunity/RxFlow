| <img alt="RxFlow Logo" src="https://raw.githubusercontent.com/RxSwiftCommunity/RxFlow/develop/Resources/RxFlow_logo.png" width="250"/> | <ul align="left"><li><a href="#about">About</a><li><a href="#navigation-concerns">Navigation concerns</a><li><a href="#rxflow-aims-to">RxFlow aims to</a><li><a href="#installation">Installation</a><li><a href="#the-core-principles">The core principles</a><li><a href="#how-to-use-rxflow">How to use RxFlow</a><li><a href="#tools-and-dependencies">Tools and dependencies</a></ul> |
| -------------- | -------------- |
| Travis CI | [![Build Status](https://travis-ci.org/RxSwiftCommunity/RxFlow.svg?branch=develop)](https://travis-ci.org/RxSwiftCommunity/RxFlow) |
| Frameworks | [![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods Compatible](https://img.shields.io/cocoapods/v/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |
| Platform | [![Platform](https://img.shields.io/cocoapods/p/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |
| Licence | [![License](https://img.shields.io/cocoapods/l/RxFlow.svg?style=flat)](http://cocoapods.org/pods/RxFlow) |

<span style="float:none" />

# About
RxFlow is a navigation framework for iOS applications based on a Flow Coordinator pattern.

This README is a short story of the whole conception process that led me to this framework.

You will find a very detail explanation of the whole project on my blog:
- [RxFlow Part 1: In Theory](https://twittemb.github.io/swift/coordinator/rxswift/rxflow/reactive%20programming/2017/11/08/rxflow-part-1-in-theory/)
- [RxFlow Part 2: In Practice](https://twittemb.github.io/swift/coordinator/reactive/rxflow/reactive%20programming/2017/12/09/rxflow-part-2-in-practice/)
- [RxFlow Part 3: Tips and Tricks](https://twittemb.github.io/swift/coordinator/reactive/rxswift/reactive%20programming/rxflow/2017/12/22/rxflow-part-3-tips-and-tricks/)

The Jazzy documentation can be seen here as well: [Documentation](http://community.rxswift.org/RxFlow/)

# Migrating from v1.0.x to v1.1.0
There are two major changes that must be taken care of if you want to use the v1.1.0 when coming from an older version:
- **Flowable** has been replaced by **NextFlowItem**. It's exactly the same idea between those 2 names, but "Flowable" was too much related to a Protocol naming convention. The **Flow.navigate(to:)** function has to return a **NextFlowItems**, which is an enum that represents different possibilities of NextFlowItem (multiple, one, none, ...). Take a look at the code snippets below to see some examples.
- In order to improve RxFlow consistency, it seemed obvious that a Flow that presents a UIViewController also **HAS** to dismiss it. In previous versions, a child Flow was dismissed by itself and not by the Flow that presented it. In the Demo Application you will find an example with the WishlistFlow dismissing the SettingsFlow for the **settingsDone** Step.

# Migrating from v1.x.x to v1.3.0
There are two major changes that must be taken care of if you want to use the v1.3.0 when coming from an older version:
- **NextFlowItems.stepNotHandled** has been removed for the sake of simplicity. If you want a received step to have no effect at all in a **navigate(to:)** function, all you need to do is returning a **NextFlowItems.none** value. It means that no new **Stepper** will be registered in the Coordinator.
- **NextFlowItems.end(withStepForParentFlow: Step)** allows to explicitly tell the Coordinator that you want to dismiss the current Flow. You can pass the Step you want the parent Flow to receive in its **navigate(to:)** function. That is where you will dismiss the child Flow root **Presentable**. It can be also used to pass data to the parent **
Flow** thanks to an enum parameter (withStepForParentFlow could be something like: DemoStep.loginIsComplete(idUser: xxx))

The DemoApp has been updated to implement those changes. It shows how to swap between 2 Flows attached to the root Window.

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

To me, the Coordinator pattern has some drawbacks:
- you have to write the coordination mechanism each time you bootstrap an application
- there can be a lot of boilerplate code because of the delegation pattern that allows to communicate with Coordinators

RxFlow is a reactive implementation of the Coordinator pattern. It has all the great features of this architecture, but introduces some improvements:
- makes the navigation more declarative
- provides a built-in Coordinator that handles the navigation flows you've declared
- uses reactive programming to address the communication with Coordinators issue

There are 6 terms you have to be familiar with to understand **RxFlow**:
- **Flow**: each **Flow** defines a navigation area within your application. This is the place where you declare the navigation actions (such as presenting a UIViewController or another Flow)
- **Step**: each **Step** is a navigation state in your application. Combinations of **Flows** and **Steps** describe all the possible navigation actions. A **Step** can even embed inner values (such as Ids, URLs, ...) that will be propagated to screens declared in the **Flows**
- **Stepper**: it can be anything that can emit **Steps**. **Steppers** will be responsible for triggering every navigation actions within the **Flows**
- **Presentable**: it is an abstraction of something that can be presented (basically **UIViewController** and **Flow** are **Presentable**). **Presentables** offer Reactive observables that the **Coordinator** will subscribe to in order to handle **Flow Steps** in a UIKit compliant way
- **NextFlowItem**: it is a simple data structure that combines a **Presentable** and a **Stepper**. It tells the **Coordinator** what will be the next thing that will produce new **Steps** in your Reactive mechanism
- **Coordinator**: once the developer has defined the suitable combinations of **Flows** and **Steps** representing the navigation possibilities, the job of the **Coordinator** is to mix these combinations in a consistent way.

# How to use RxFlow

## Code samples

### How to declare **Steps**

As **Steps** are seen like some navigation states spread across the application, it seems pretty obvious to use an enum to declare them

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

The following **Flow** is used as a Navigation stack. All you have to do is:
- declare a root UIViewController on which your navigation will be based
- implement the **navigate(to:)** function to transform a **Step** into a navigation action

The **navigate(to:)** function returns a **NextFlowItems**. This is how the next navigation actions will be produced (the **Stepper** defined in a **NextFlowItem** will emit the next **Steps**)

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

    func navigate(to step: Step) -> NextFlowItems {

        guard let step = step as? DemoStep else { return NextFlowItems.none }

        switch step {

        case .movieList:
            return navigateToMovieListScreen()
        case .moviePicked(let movieId):
            return navigateToMovieDetailScreen(with: movieId)
        case .castPicked(let castId):
            return navigateToCastDetailScreen(with: castId)
        default:
            return NextFlowItems.none
    	}
    }

    private func navigateToMovieListScreen () -> NextFlowItems {
        let viewModel = WatchedViewModel(with: self.service)
        let viewController = WatchedViewController.instantiate(with: viewModel)
        viewController.title = "Watched"
        self.rootViewController.pushViewController(viewController, animated: true)
	return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewModel))
    }

    private func navigateToMovieDetailScreen (with movieId: Int) -> NextFlowItems {
        let viewModel = MovieDetailViewModel(withService: self.service, andMovieId: movieId)
        let viewController = MovieDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.title
        self.rootViewController.pushViewController(viewController, animated: true)
	return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: viewController, nextStepper: viewModel))
    }

    private func navigateToCastDetailScreen (with castId: Int) -> NextFlowItems {
        let viewModel = CastDetailViewModel(withService: self.service, andCastId: castId)
        let viewController = CastDetailViewController.instantiate(with: viewModel)
        viewController.title = viewModel.name
        self.rootViewController.pushViewController(viewController, animated: true)
        return NextFlowItems.none
    }
}
```

### How to declare a **Stepper**

In theory a **Stepper**, as it is a protocol, can be anything (a UIViewController for instance) by I suggest to isolate that behavior in a ViewModel or so.
For simple cases (for instance when we only need to bootstrap a **Flow** with a first **Step** and don't want to code a basic **Stepper** for that), RxFlow provides a **OneStepper** class.

```swift
class WatchedViewModel: Stepper {

    let movies: [MovieViewModel]

    init(with service: MoviesService) {
        // we can do some data refactoring in order to display things exactly the way we want (this is the aim of a ViewModel)
        self.movies = service.watchedMovies().map({ (movie) -> MovieViewModel in
            return MovieViewModel(id: movie.id, title: movie.title, image: movie.image)
        })
    }

    // when a movie is picked, a new Step is emitted.
    // That will trigger a navigation action within the WatchedFlow
    public func pick (movieId: Int) {
        self.step.accept(DemoStep.moviePicked(withMovieId: movieId))
    }

}
```

### Is it possible to coordinate multiple Flows ?

Of course, it is the aim of a Coordinator. As a Flow is a Presentable, a Flow can launch one other Flow or even several other Flows.

For instance, from the WishlistFlow, we launch the SettingsFlow in a popup.

```swift
private func navigateToSettings () -> NextFlowItems {     
    let settingsStepper = SettingsStepper()
    let settingsFlow = SettingsFlow(withService: self.service, andStepper: settingsStepper)
    Flows.whenReady(flow: settingsFlow, block: { [unowned self] (root: UISplitViewController) in
        self.rootViewController.present(root, animated: true)
    })
    return NextFlowItems.one(flowItem: NextFlowItem(nextPresentable: settingsFlow, nextStepper: settingsStepper))
}
```

For a more complex case, see the **MainFlow.swift** file in which we handle a UITabBarController.

### How to bootstrap the RxFlow process

The coordination process is pretty straightfoward and happens in the AppDelegate.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate {

    let disposeBag = DisposeBag()
    var window: UIWindow?
    var coordinator = Coordinator()
    let movieService = MoviesService()
    lazy var appFlow = {
    	return AppFlow(with: self.movieService)
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard let window = self.window else { return false }

        // listen for Coordinator mechanism is not mandatory
        coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
            print ("did navigate to flow=\(flow) and step=\(step)")
        }).disposed(by: self.disposeBag)

        // when the MainFlow is ready to be displayed, we assign its root the the Window
        Flows.whenReady(flow: appFlow, block: { [unowned window] (flowRoot) in
            window.rootViewController = flowRoot
        })

        // The navigation begins with the MainFlow at the apiKey Step
        // We could also have a specific Stepper that could decide if
        // the apiKey should be the fist step or not
        coordinator.coordinate(flow: appFlow, withStepper: OneStepper(withSingleStep: DemoStep.apiKey))

        return true
    }
}
```

As a bonus, **Coordinator** offers a Rx extension that allows you to track the navigation actions (Coordinator.rx.willNavigate and Coordinator.rx.didNavigate).

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


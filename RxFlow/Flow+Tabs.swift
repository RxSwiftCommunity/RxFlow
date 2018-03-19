//
//  Flow+Tabs.swift
//  RxFlow
//
//  Created by Alexander Cyon on 2018-03-19.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import RxSwift
import UIKit

public typealias TabsReady<RootViewController: UIViewController> = ([(RootViewController, UITabBarItem)]) -> Void

public extension Flows {
    
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - tabs: List of Tab containing flows which should be observed
    ///   - block: block to execute whenever the Flows are ready to use
    public static func whenReady<RootType: UIViewController>(
        tabs: [TabFlowContainer],
        block: @escaping TabsReady<RootType>) {
        let flows = tabs.map { $0.flow }
        guard case let roots = flows.flatMap({ $0.root as? RootType }), roots.count == tabs.count else {
            fatalError ("Type mismatch, Flows roots types do not match the types awaited in the block")
        }
        
        let tabbedRoots = zip(roots, tabs.map { $0.tab }).map { ($0.0, $0.1) }
        
        _ = Observable<Void>.zip(flows.map { $0.rxFlowReady.asObservable() }) { _ in return Void() }
            .take(1)
            .subscribe(onNext: { _ in
                block(tabbedRoots)
            })
    }
    
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - tabsWithSteppers: List of Tab and stepper contains flows which should be observed
    ///   - weak: Target to weakify being used in the `block` parameter
    ///   - block: block executed when the Flow in each tab is ready, exposing the rootViewController having the tabItem set
    /// - Returns: the NextFlowItems created from the tabs
    public static func whenReady<Target: AnyObject, RootType: UIViewController>(
        tabsWithSteppers tabs: [TabWithStepperFlowContainer],
        weak target: Target,
        block: @escaping (Target, [RootType]) -> Void) -> [NextFlowItem] {
        
        let mappedblock: TabsReady<RootType> = { [weak target] (tabbedRoots: [(RootType, UITabBarItem)]) -> Void in
            guard let indeedTarget = target else { print("⚠️ WARNING Target was nil, this is probably unwanted."); return }
            tabbedRoots.forEach { $0.0.tabBarItem = $0.1 }
            block(indeedTarget, tabbedRoots.map { $0.0 })
        }
        
        Flows.whenReady(tabs: tabs, block: mappedblock)
        
        // We can safely return the array of NextFlowItems since it is not dependent on the async call above
        return tabs.map { NextFlowItem(nextPresentable: $0.flow, nextStepper: $0.stepper) }
    }
    
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - tabsWithSteppers: List of Tab and stepper contains flows which should be observed
    ///   - weak: Target to weakify being used in the `block` parameter
    ///   - block: block executed when the Flow in each tab is ready, exposing the rootViewController having the tabItem set
    /// - Returns: the NextFlowItems created from the tabs
    public static func whenReady<Target: AnyObject>(
        createTabBarWith tabs: [TabWithStepperFlowContainer],
        weak target: Target,
        block: @escaping (Target, UITabBarController) -> Void) -> [NextFlowItem] {
        
        let mappedblock: TabsReady<UIViewController> = { [weak target] (tabbedRoots: [(UIViewController, UITabBarItem)]) -> Void in
            guard let indeedTarget = target else { print("⚠️ WARNING Target was nil, this is probably unwanted."); return }
            tabbedRoots.forEach { $0.0.tabBarItem = $0.1 }
            let tabBarController = UITabBarController()
            tabBarController.setViewControllers(tabbedRoots.map { $0.0 }, animated: false)
            block(indeedTarget, tabBarController)
        }
        
        Flows.whenReady(tabs: tabs, block: mappedblock)
        
        // We can safely return the array of NextFlowItems since it is not dependent on the async call above
        return tabs.map { NextFlowItem(nextPresentable: $0.flow, nextStepper: $0.stepper) }
    }
    
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the rootViewControllers are set on the tabBarController.
    ///
    /// - Parameters:
    ///   - tabsWithSteppers: List of Tab that contains flows that should be observed
    ///   - tabBarController: UITabBarController that will get `rootViewControllers` property set using the rootViewController of each tab.
    ///   - animated: Bool that controls whether or not setting the `rootViewControllers` property should be animated.
    /// - Returns: the NextFlowItems created from the tabs
    public static func whenReady(
        setupTabBarController tabBarController: UITabBarController,
        with tabs: [TabWithStepperFlowContainer],
        animated: Bool = false) -> [NextFlowItem] {
        
        let block: TabsReady<UIViewController> = { (tabbedRoots: [(UIViewController, UITabBarItem)]) -> Void in
            tabbedRoots.forEach { $0.0.tabBarItem = $0.1 }
            tabBarController.setViewControllers(tabbedRoots.map { $0.0 }, animated: animated)
        }
        
        Flows.whenReady(tabs: tabs, block: block)
        
        // We can safely return the array of NextFlowItems since it is not dependent on the async call above
        return tabs.map { NextFlowItem(nextPresentable: $0.flow, nextStepper: $0.stepper) }
    }
}

//MARK: - NextFlowItems.multiple Convenience
public extension Flows {
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - tabsWithSteppers: List of OneStepperTab that contains flows that should be observed
    ///   - weak: Target to weakify being used in the `block` parameter
    ///   - block: block to execute whenever the Flows are ready to use, having set the tabItems on each viewController
    /// - Returns: the NextFlowItems created from the tabs, as a "multiple" type
    public static func whenReady<Target: AnyObject, RootType: UIViewController>(
        tabsWithSteppers tabs: [TabWithStepperFlowContainer],
        weak target: Target,
        block: @escaping (Target, [RootType]) -> Void) -> NextFlowItems {
        return .multiple(flowItems: Flows.whenReady(tabsWithSteppers: tabs, weak: target, block: block))
    }
    
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - tabsWithSteppers: List of OneStepperTab that contains flows that should be observed
    ///   - weak: Target to weakify being used in the `block` parameter
    ///   - block: block to execute whenever the Flows are ready to use, having set the tabItems on each viewController
    /// - Returns: the NextFlowItems created from the tabs, as a "multiple" type
    public static func whenReady(
        setupTabBarController tabBarController: UITabBarController,
        with tabs: [TabWithStepperFlowContainer],
        animated: Bool = false) -> NextFlowItems {
        return .multiple(flowItems: Flows.whenReady(setupTabBarController: tabBarController, with: tabs, animated: animated))
    }
    
    /// Allow to be triggered only when Flows given as parameters are ready to be displayed.
    /// Once it is the case, the block is executed
    ///
    /// - Parameters:
    ///   - tabsWithSteppers: List of Tab and stepper contains flows which should be observed
    ///   - weak: Target to weakify being used in the `block` parameter
    ///   - block: block executed when the Flow in each tab is ready, exposing the rootViewController having the tabItem set
    /// - Returns: the NextFlowItems created from the tabs
    public static func whenReady<Target: AnyObject>(
        createTabBarWith tabs: [TabWithStepperFlowContainer],
        weak target: Target,
        block: @escaping (Target, UITabBarController) -> Void) -> NextFlowItems {
        return .multiple(flowItems: Flows.whenReady(createTabBarWith: tabs, weak: target, block: block))
    }
    
}

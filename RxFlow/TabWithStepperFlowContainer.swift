//
//  TabWithStepperFlowContainer.swift
//  RxFlow
//
//  Created by Alexander Cyon on 2018-03-19.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation

open class TabWithStepperFlowContainer: TabFlowContainer {
    public let stepper: Stepper
    public init(flow: Flow, tab: UITabBarItem, stepper: Stepper) {
        self.stepper = stepper
        super.init(flow: flow, tab: tab)
    }
}

public extension TabWithStepperFlowContainer {
    
    public convenience init(flow: Flow,
                            title: String,
                            image: UIImage? = nil,
                            selectedImage: UIImage? = nil,
                            stepper: Stepper) {
        let tab = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        self.init(flow: flow, tab: tab, stepper: stepper)
    }
    
    public convenience init(flow: Flow,
                            title: String,
                            image: UIImage? = nil,
                            selectedImage: UIImage? = nil,
                            withSingleStep step: Step,
                            stepperFactory: ((Step) -> Stepper) = OneStepper.init(withSingleStep:)) {
        let tab = UITabBarItem(title: title, image: image, selectedImage: selectedImage)
        self.init(flow: flow, tab: tab, stepper: stepperFactory(step))
    }
}


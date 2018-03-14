//
//  Tab.swift
//  RxFlow
//
//  Created by Alexander Cyon on 2018-03-14.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation

open class Tab {
    public let flow: Flow
    let title: String
    public init<F>(flow: F, title: String) where F: Flow {
        self.flow = flow
        self.title = title
    }
}

open class OneStepperTab: Tab {
    let step: Step
    public init<F>(flow: F, step: Step, title: String) where F: Flow {
        self.step = step
        super.init(flow: flow, title: title)
    }
}

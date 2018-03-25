//
//  TabFlowContainer.swift
//  RxFlow
//
//  Created by Alexander Cyon on 2018-03-14.
//  Copyright © 2018 RxSwiftCommunity. All rights reserved.
//

import Foundation

open class TabFlowContainer {
    public let flow: Flow
    public let tab: UITabBarItem
    public init(flow: Flow, tab: UITabBarItem) {
        self.flow = flow
        self.tab = tab
    }
}

public extension TabFlowContainer {

    public convenience init(flow: Flow, title: String) {
        self.init(flow: flow, title: title)
    }
    
    public convenience init(flow: Flow, image: String, selectedImage: UIImage? = nil) {
        self.init(flow: flow, image: image, selectedImage: selectedImage)
    }
    
    public convenience init(flow: Flow,
                            title: String?,
                            image: UIImage? = nil,
                            selectedImage: UIImage? = nil) {
        self.init(flow: flow, tab: UITabBarItem(title: title, image: image, selectedImage: selectedImage))
    }
}

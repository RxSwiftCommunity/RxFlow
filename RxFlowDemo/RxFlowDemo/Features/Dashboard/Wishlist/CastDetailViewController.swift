//
//  DashboardViewController1.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-07-26.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable
import RxFlow
import RxSwift
import RxCocoa

class CastDetailViewController: UIViewController, XibBased, ViewModelBased {
    
    var viewModel: CastDetailViewModel!
    
    @IBOutlet private weak var castBanner: UIImageView!
    @IBOutlet private weak var castBio: UILabel!
    
    init() {
        super.init(nibName: "CastDetailViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.castBanner.image = UIImage(named: self.viewModel.image)
        self.castBio.text = self.viewModel.bio
    }
}


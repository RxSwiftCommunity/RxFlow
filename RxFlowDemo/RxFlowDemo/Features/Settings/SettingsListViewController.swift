//
//  SettingsListViewController.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-11-13.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable
import RxFlow

class SettingsListViewController: UITableViewController, StoryboardBased, Stepper {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.selectRow(at: IndexPath(row: 0, section: 0),
                                 animated: false,
                                 scrollPosition: UITableViewScrollPosition.none)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.step.accept(DemoStep.apiKey)
        case 1:
            self.step.accept(DemoStep.about)
        default:
            return
        }
    }

}

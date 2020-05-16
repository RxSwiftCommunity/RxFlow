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

class WishlistViewController: UIViewController, StoryboardBased, ViewModelBased {

    @IBOutlet private weak var moviesTable: UITableView!

    var viewModel: WishlistViewModel!
    let steps = PublishRelay<Step>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.moviesTable.delegate = self
        self.moviesTable.dataSource = self

        _ = Observable<Int>
            .interval(.seconds(5), scheduler: MainScheduler.instance)
            .takeUntil(self.rx.deallocating)
            .map { _ in return DemoStep.fakeStep }
            .bind(to: self.steps)
    }

    @IBAction func sendNotification(_ sender: UIButton) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, _) in

            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "Notification from RxFlow"
            content.subtitle = "Deeplink use case"
            content.body = "Click to navigate to Avatar"

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "\(UUID())", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    @IBAction func about(_ sender: UIButton) {
        self.about()
    }
}

extension WishlistViewController: Stepper {
    private func about () {
        self.steps.accept(DemoStep.aboutIsRequired)
    }
}

extension WishlistViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.movies.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.pick(movieId: self.viewModel.movies[indexPath.item].id)
    }
}

extension WishlistViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: MovieViewCell!

        if let movieViewCell = tableView.dequeueReusableCell(withIdentifier: "movieViewCell") as? MovieViewCell {
            cell = movieViewCell
        } else {
            cell = MovieViewCell()
        }

        cell.movieTitle.text = self.viewModel.movies[indexPath.item].title
        cell.movieImage.image = UIImage(named: self.viewModel.movies[indexPath.item].image)
        return cell
    }
}

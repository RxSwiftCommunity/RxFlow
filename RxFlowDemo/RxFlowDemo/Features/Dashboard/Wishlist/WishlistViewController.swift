//
//  DashboardViewController1.swift
//  RxFlowDemo
//
//  Created by Thibault Wittemberg on 17-07-26.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

import UIKit
import Reusable
import RxFlow
import RxSwift
import RxCocoa

class WishlistViewController: UIViewController, StoryboardBased, ViewModelBased {

    @IBOutlet private weak var moviesTable: UITableView!

    var viewModel: WishlistViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.moviesTable.delegate = self
        self.moviesTable.dataSource = self
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

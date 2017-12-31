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

class WatchedViewController: UIViewController, StoryboardBased, ViewModelBased {

    @IBOutlet private weak var moviesCollection: UICollectionView!

    var viewModel: WatchedViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.moviesCollection.delegate = self
        self.moviesCollection.dataSource = self
    }

}

extension WatchedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.movies.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.pick(movieId: self.viewModel.movies[indexPath.item].id)
    }
}

extension WatchedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: MovieCollectionViewCell!

        if let movieViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell {
            cell = movieViewCell
        } else {
            cell = MovieCollectionViewCell()
        }

        cell.movieTitle.text = self.viewModel.movies[indexPath.item].title
        cell.movieImage.image = UIImage(named: self.viewModel.movies[indexPath.item].image)
        return cell
    }

}

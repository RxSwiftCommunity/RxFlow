//
//  CastListViewController.swift
//  RxFlowDemo
//
//  Created by Li Hao Lai on 30/9/20.
//  Copyright © 2020 RxSwiftCommunity. All rights reserved.
//

import UIKit
import Reusable

class CastListViewController: UIViewController, ViewModelBased, StoryboardBased {
    typealias ViewModelType = CastListViewModel

    var viewModel: CastListViewModel!

    @IBOutlet weak var castsCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.castsCollection.delegate = self
        self.castsCollection.dataSource = self
    }
}

extension CastListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.casts.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.pick(castId: self.viewModel.casts[indexPath.item].id)
    }
}

extension CastListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: CastCollectionViewCell!

        if let castViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "castCollectionViewCell", for: indexPath) as? CastCollectionViewCell {
            cell = castViewCell
        } else {
            cell = CastCollectionViewCell()
        }

        cell.castImage.image = UIImage(named: self.viewModel.casts[indexPath.item].image)
        return cell
    }

}

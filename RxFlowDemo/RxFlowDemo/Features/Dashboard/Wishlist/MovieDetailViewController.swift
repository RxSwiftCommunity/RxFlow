//
//  DashboardViewController2.swift
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

class MovieDetailViewController: UIViewController, StoryboardBased, ViewModelBased {

    @IBOutlet private weak var castButton: UIButton!
    @IBOutlet private weak var castButton2: UIButton!
    @IBOutlet private weak var castButton3: UIButton!
    @IBOutlet private weak var castButton4: UIButton!
    @IBOutlet private weak var castButton5: UIButton!
    @IBOutlet private weak var castLabel: UILabel!
    @IBOutlet private weak var castLabel2: UILabel!
    @IBOutlet private weak var castLabel3: UILabel!
    @IBOutlet private weak var castLabel4: UILabel!
    @IBOutlet private weak var castLabel5: UILabel!

    @IBOutlet private weak var movieBanner: UIImageView!
    @IBOutlet private weak var movieDescription: UILabel!
    @IBOutlet private weak var movieYear: UILabel!
    @IBOutlet private weak var movieDirector: UILabel!
    @IBOutlet private weak var movieWriter: UILabel!
    @IBOutlet private weak var movieBudget: UILabel!

    var viewModel: MovieDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.castButton.setImage(UIImage(named: self.viewModel.casts[0].image), for: .normal)
        self.castButton2.setImage(UIImage(named: self.viewModel.casts[1].image), for: .normal)
        self.castButton3.setImage(UIImage(named: self.viewModel.casts[2].image), for: .normal)
        self.castButton4.setImage(UIImage(named: self.viewModel.casts[3].image), for: .normal)
        self.castButton5.setImage(UIImage(named: self.viewModel.casts[4].image), for: .normal)

        self.castLabel.text = self.viewModel.casts[0].name
        self.castLabel2.text = self.viewModel.casts[1].name
        self.castLabel3.text = self.viewModel.casts[2].name
        self.castLabel4.text = self.viewModel.casts[3].name
        self.castLabel5.text = self.viewModel.casts[4].name

        self.movieBanner.image = UIImage(named: self.viewModel.image)
        self.movieDescription.text = self.viewModel.description
        self.movieYear.text = self.viewModel.year
        self.movieDirector.text = self.viewModel.director
        self.movieWriter.text = self.viewModel.writer
        self.movieBudget.text = self.viewModel.budget
    }

    @IBAction func pickCast(_ sender: UIButton) {
        self.viewModel.pick(castId: self.viewModel.casts[0].id)
    }

    @IBAction func pickCast2(_ sender: UIButton) {
        self.viewModel.pick(castId: self.viewModel.casts[1].id)
    }

    @IBAction func pickCast3(_ sender: UIButton) {
        self.viewModel.pick(castId: self.viewModel.casts[2].id)
    }

    @IBAction func pickCast4(_ sender: UIButton) {
        self.viewModel.pick(castId: self.viewModel.casts[3].id)
    }

    @IBAction func pickCast5(_ sender: UIButton) {
        self.viewModel.pick(castId: self.viewModel.casts[4].id)
    }
}

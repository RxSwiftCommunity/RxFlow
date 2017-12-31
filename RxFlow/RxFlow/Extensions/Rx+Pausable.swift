//
//  Rx+Pausable.swift
//  RxFlow
//
//  Created by Thibault Wittemberg on 17-10-01.
//  Copyright © 2017 Warp Factor. All rights reserved.
//

import RxSwift

// this code had been inspired by the project: https://github.com/RxSwiftCommunity/RxSwiftExt
// Its License can be found here: ../DependenciesLicenses/RxSwiftCommunity-RxSwiftExt-License

extension ObservableType {

    /// Pauses the elements of the source observable sequence based on the latest element from the second observable sequence.
    /// Elements are ignored unless the second sequence has most recently emitted `true`.
    /// seealso: [pausable operator on reactivex.io](http://reactivex.io/documentation/operators/backpressure.html)
    ///
    /// - Parameter pauser: The observable sequence used to pause the source observable sequence.
    /// - Returns: The observable sequence which is paused based upon the pauser observable sequence.
    public func pausable<P: ObservableType> (_ pauser: P) -> Observable<E> where P.E == Bool {
        return withLatestFrom(pauser) { element, paused in
            (element, paused)
            }.filter { _, paused in
                paused
            }.map { element, _ in
                element
        }
    }
}

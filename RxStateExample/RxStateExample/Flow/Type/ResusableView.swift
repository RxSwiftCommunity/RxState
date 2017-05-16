//
//  ResusableView.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import UIKit
import RxSwift

protocol ResusableView: class {
    func disposeOnReuse()
}

extension ResusableView where Self: UIView, Self: HasDisposeBag {
    func disposeOnReuse() {

        var hasDisposeBag = self as HasDisposeBag
        hasDisposeBag.disposeBag = DisposeBag()

        for case let resusableView as ResusableView in subviews {
            resusableView.disposeOnReuse()
        }
    }
}

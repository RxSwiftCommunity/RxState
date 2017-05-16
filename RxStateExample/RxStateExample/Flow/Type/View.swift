//
//  View.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift

protocol ViewType: HasDisposeBag, ResusableView {}

class View: UIView, ViewType {
    var disposeBag = DisposeBag()
}

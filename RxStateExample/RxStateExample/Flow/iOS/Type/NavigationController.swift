//
//  NavigationController.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift

protocol NavigationControllerType: HasDisposeBag, Identifiable, SubjectLabelable {}

class NavigationController: UINavigationController, NavigationControllerType {
    var disposeBag = DisposeBag()
    let id = Foundation.UUID().uuidString
}

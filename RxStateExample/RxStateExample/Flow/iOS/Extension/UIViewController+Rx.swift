//
//  UIViewController.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {

    var viewDidLoad: Observable<Void> {
        return sentMessage(#selector(Base.viewDidLoad)).map { _ in Void() }
    }

    var viewWillAppear: Observable<Void> {
        return sentMessage(#selector(Base.viewWillAppear)).map { _ in Void() }
    }

    var viewDidAppear: Observable<Void> {
        return sentMessage(#selector(Base.viewDidAppear)).map { _ in Void() }
    }

    var viewWillDisappear: Observable<Void> {
        return sentMessage(#selector(Base.viewWillDisappear)).map { _ in Void() }
    }

    var viewDidDisappear: Observable<Void> {
        return sentMessage(#selector(Base.viewDidDisappear)).map { _ in Void() }
    }

    var viewWillLayoutSubviews: Observable<Void> {
        return sentMessage(#selector(Base.viewWillLayoutSubviews)).map { _ in Void() }
    }

    var viewDidLayoutSubviews: Observable<Void> {
        return sentMessage(#selector(Base.viewDidLayoutSubviews)).map { _ in Void() }
    }
}

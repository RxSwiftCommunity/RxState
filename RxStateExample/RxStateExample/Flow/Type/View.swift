//
//  View.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import RxSwift

protocol ViewType: HasDisposeBag, ResusableView {}

#if os(iOS)
    import UIKit
    typealias OSView = UIView
#endif

#if os(macOS)
    import Cocoa
    typealias OSView = NSView
#endif

class View: OSView, ViewType {
    var disposeBag = DisposeBag()
}

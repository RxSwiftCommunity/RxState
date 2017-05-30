//
//  ResusableView.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift

protocol ResusableView: class {
    func disposeOnReuse()
}

#if os(iOS)
    import class UIKit.UIView
    
    extension ResusableView where Self: UIView {
        func disposeOnReuse() {
            
            if var hasDisposeBag = self as? HasDisposeBag {
                hasDisposeBag.disposeBag = DisposeBag()
            }
            
            for case let resusableView as ResusableView in subviews {
                resusableView.disposeOnReuse()
            }
        }
    }
    
#endif

#if os(macOS)
    
    import class Cocoa.NSView
    
    extension ResusableView where Self: NSView {
        func disposeOnReuse() {
            
            if var hasDisposeBag = self as? HasDisposeBag {
                hasDisposeBag.disposeBag = DisposeBag()
            }
            
            for case let resusableView as ResusableView in subviews {
                resusableView.disposeOnReuse()
            }
        }
    }
    
#endif

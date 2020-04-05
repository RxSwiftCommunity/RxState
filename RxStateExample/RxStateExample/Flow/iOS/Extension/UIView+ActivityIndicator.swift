//
//  UIView+ActivityIndicator.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa


extension Reactive where Base: UIView {
    /// Bindable sink for `enabled` property.
    public var activityIndicatorIsAnimating: Binder<Bool> {
        return Binder(self.base) { view, value in
            view.activityIndicatorIsAnimating = value
        }
        
    }
}

extension UIView {
    var activityIndicatorTag: Int { return 999_999 }
    
    var activityIndicatorIsAnimating: Bool {
        get {
            if let activityIndicator = self.subviews.filter({ $0.tag == self.activityIndicatorTag }).first as? UIActivityIndicatorView
                , activityIndicator.isAnimating {
                return true
            } else {
                return false
            }
        }
        set {
            let activityIndicatorExist = self.subviews
                .contains(where: { (view: UIView) -> Bool in
                    view.tag == activityIndicatorTag
                })
            
            guard newValue != activityIndicatorExist else { return }
            
            if newValue {
                let activityIndicator = { () -> UIActivityIndicatorView in
                    let location = self.center
                    
                    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
                    // Add the tag so we can find the view in order to remove it later
                    activityIndicator.tag = self.activityIndicatorTag
                    
                    activityIndicator.center = location

                    activityIndicator.hidesWhenStopped = true
                    
                    // Start animating and add the view
                    activityIndicator.startAnimating()
                    return activityIndicator
                }()
                
                self.addSubview(activityIndicator)
                
            } else {
                
                // Here we find the `UIActivityIndicatorView` and remove it from the view
                guard let activityIndicator = self.subviews.filter({ $0.tag == self.activityIndicatorTag }).first as? UIActivityIndicatorView
                    else { return }
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
}

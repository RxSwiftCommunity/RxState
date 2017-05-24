//
//  NibLoadable.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit

protocol NibLoadable {}

extension NibLoadable where Self: UIViewController {
    static func loadFromNib() -> Self {
        let viewController = Self(nibName: Self.subjectLabel, bundle: Bundle(for: self))
        return viewController
    }
}

extension UIViewController: NibLoadable {}

extension NibLoadable where Self: UIView {
    static func loadFromNib() -> Self {
        let nib = UINib(nibName: Self.subjectLabel, bundle: Bundle(for: self))
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The root view in \(nib) nib must be of type \(self)")
        }
        return view
    }
}

extension UIView: NibLoadable {}

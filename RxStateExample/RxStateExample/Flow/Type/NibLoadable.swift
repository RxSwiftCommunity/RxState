//
//  NibLoadable.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

protocol NibLoadable {}

#if os(iOS)
    import UIKit
    
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
    
#endif

#if os(macOS)
    import Cocoa
    
    extension NibLoadable where Self: NSViewController {
        static func loadFromNib() -> Self {
            guard let viewController = Self(nibName: Self.subjectLabel, bundle: Bundle(for: self)) else {
                fatalError("nib: \(Self.subjectLabel) not found")
            }
            return viewController
        }
    }
    
    extension NSViewController: NibLoadable {}
    
    extension NibLoadable where Self: NSView {
        static func loadFromNib() -> Self {
            guard let nib = NSNib(nibNamed: Self.subjectLabel, bundle: Bundle(for: self)) else {
                fatalError("nib: \(Self.subjectLabel) not found")
            }
            
            var topLevelObjects = NSArray()
            guard Bundle(for: self).loadNibNamed(Self.subjectLabel, owner: self, topLevelObjects: &topLevelObjects)
                , let view = (topLevelObjects as Array).first(where: { (objsect: AnyObject) -> Bool in
                    return objsect is Self
                }) as? Self else{
                fatalError("The root view in \(nib) nib must be of type \(self)")
            }
            return view
        }
    }
    
    extension NSView: NibLoadable {}
    
#endif

//
//  NavigatableController.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

#if os(iOS)
    import UIKit

    final class NavigatableController: CustomDebugStringConvertible {
        weak var viewController: UIViewController?
        weak var navigationController: UINavigationController?
        weak var tabBarController: UITabBarController?
        
        init(){
            self.viewController = nil
            self.navigationController = nil
            self.tabBarController = nil
        }
        
        init(
            viewController: UIViewController?
            , navigationController: UINavigationController?
            , tabBarController: UITabBarController?
            ) {
            self.viewController = viewController
            self.navigationController = navigationController
            self.tabBarController = tabBarController
        }
        
        var debugDescription: String {
            return "viewController: \(String(describing: viewController))"
                .appending("\nnavigationController: \(String(describing: navigationController))")
                .appending("\ntabBarController: \(String(describing: tabBarController))")
        }
    }
#endif

#if os(macOS)
    import Cocoa
    
    final class NavigatableController: CustomDebugStringConvertible {
        weak var viewController: NSViewController?
        
        init(){
            self.viewController = nil
        }
        
        init(
            viewController: NSViewController? = nil
            ) {
            self.viewController = viewController
        }
        
        var debugDescription: String {
            return "viewController: \(String(describing: viewController))"
        }
    }
#endif

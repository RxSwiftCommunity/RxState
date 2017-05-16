//
//  main.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import UIKit

private func appDelegateClassName() -> String {
    let isTesting = NSClassFromString("XCTestCase") != nil
    return NSStringFromClass(isTesting ? AppDelegateMock.self : AppDelegate.self)
}

UIApplicationMain(
    CommandLine.argc
    , UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))
    , NSStringFromClass(UIApplication.self)
    , appDelegateClassName()
)

//
//  Route.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import UIKit

enum Route: Equatable {
    case root
    case tasks
    case task(id: String)
    
    static func ==(lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.root, root):
            return true
            
        case (let .task(lhsId), let task(rhsId)):
            return lhsId == rhsId
            
        case (.tasks, .tasks):
            return true
            
        default:
            return false
        }
    }
}

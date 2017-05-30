//
//  Route.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation

#if os(iOS)
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
    
#endif

#if os(macOS)
    enum Route: Equatable {
        static func ==(lhs: Route, rhs: Route) -> Bool {
            return true
        }
    }
#endif

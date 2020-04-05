//
//  Tupe+Equatable.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation

func == <T1:Equatable, T2: Equatable>(lhs: (T1, T2)?, rhs: (T1, T2)?) -> Bool {
    if case .none = lhs, case .none = rhs {
        return true
    }
    
    if case let .some(lhsValue) = lhs, case let .some(rhsValue) = rhs {
        return lhsValue == rhsValue
    }
    
    return false
}

func == <T1:Equatable, T2: Equatable>(lhs: (T1, T2), rhs: (T1, T2)) -> Bool {
    
    return lhs.0 == rhs.0 && lhs.1 == rhs.1
}

//
//  Identifiable.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation

protocol Identifiable: Hashable {
    associatedtype Identifier: Hashable
    var id: Identifier { get }
}

extension Identifiable {
    var hashValue: Int {
        return id.hashValue
    }
}

extension Equatable where Self: Identifiable {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Collection where Self.Iterator.Element: Identifiable {
    func index(of element: Self.Iterator.Element) -> Self.Index? {
        return index { $0.id == element.id }
    }
}

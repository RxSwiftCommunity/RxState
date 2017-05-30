//
//  ActionCreatorType.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

protocol ActionCreatorType {
    associatedtype I: ActionCreatorInputsType
    static func create(inputs: I) -> Driver<ActionType>
    init()
}

extension ActionCreatorType {
    init() {
        fatalError("`ActionCreator` class is only to group the pure `create` methods and the it's input data structure definition (The `create` methods always return `Driver<ActionType>). It doesn't contain any properties or functions")
    }
}

protocol ActionCreatorInputsType {
    var store: StoreType { get }
}

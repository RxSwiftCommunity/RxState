//
//  TransformerType.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxState

protocol TransformerType {
    associatedtype I: TransformerInputsType
    associatedtype O: TransformerOutputsType
    static func transtorm(inputs: I) -> O
    init()
}

extension TransformerType{
    init() {
        fatalError("`Transformer` class is only to group the pure `transform` methods and the it's inputs and outputs data structure definition. It doesn't contain any properties or functions")
    }
}

protocol TransformerInputsType {
    var store: StoreType { get }
}

protocol TransformerOutputsType {}


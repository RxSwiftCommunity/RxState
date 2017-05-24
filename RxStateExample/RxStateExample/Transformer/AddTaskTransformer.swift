//
//  AddTaskTransformer.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxState

final class AddTaskButtonActivityIndicatorIsAnimatingTransformer: TransformerType {
    struct Inputs: TransformerInputsType {
        let store: StoreType
    }
    
    struct Outputs: TransformerOutputsType {
        let addTaskButtonActivityIndicatorIsAnimating: Driver<Bool>
    }
    
    static func transtorm(inputs: AddTaskButtonActivityIndicatorIsAnimatingTransformer.Inputs) -> AddTaskButtonActivityIndicatorIsAnimatingTransformer.Outputs {
        let addTaskButtonActivityIndicatorIsAnimating = inputs.store.tasksState
            .map { (tasksState: Store.TasksState) -> Bool in
                return tasksState.addingTask
        }
        
        return AddTaskButtonActivityIndicatorIsAnimatingTransformer.Outputs(addTaskButtonActivityIndicatorIsAnimating: addTaskButtonActivityIndicatorIsAnimating)
    }
}

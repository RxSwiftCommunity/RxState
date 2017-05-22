//
//  AddTaskTransformer.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxState

class AddTaskTransformer {
    struct Inputs {
        let store: StoreType
    }
    
    struct Outputs {
        let addTaskButtonActivityIndicatorISAnimating: Driver<Bool>
    }
    
    static func transform(inputs: AddTaskTransformer.Inputs) -> AddTaskTransformer.Outputs {
        let addTaskButtonActivityIndicatorISAnimating = inputs.store.tasksState
            .map { (tasksState: TasksStateManager.State) -> Bool in
                return tasksState.addingTask
        }
        
        return AddTaskTransformer.Outputs(addTaskButtonActivityIndicatorISAnimating: addTaskButtonActivityIndicatorISAnimating)
    }
}

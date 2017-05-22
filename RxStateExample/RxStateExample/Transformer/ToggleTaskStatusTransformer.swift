//
//  ToggleTaskStatusTransformer.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxState

class ToggleTaskStatusTransformer {
    struct Inputs {
        let store: StoreType
        let taskId: TaskId
    }
    
    struct Outputs {
        let toggleTaskStatusButtonIsSelected: Driver<Bool>
        let toggleTaskStatusButtonIsEnabled: Driver<Bool>
        let toggleTaskStatusButtonActivityIndicatorIsAnimating: Driver<Bool>
    }
    
    static func transtorm(inputs: ToggleTaskStatusTransformer.Inputs) -> ToggleTaskStatusTransformer.Outputs {
        

        let toggleTaskStatusButtonIsSelected = inputs.store.task(withId: inputs.taskId)
            .map { (task: Task) -> Bool in
                return task.status == .done
            }
            .distinctUntilChanged()
        
        let toggleTaskStatusButtonIsEnabled = store.tasksState
            .map { (tasksState: TasksStateManager.State) -> Bool in
                return !tasksState.togglingTaskStatusForTasksWithIds.contains(inputs.taskId)
            }
            .distinctUntilChanged()
        
        
        let toggleTaskStatusButtonActivityIndicatorIsAnimating = toggleTaskStatusButtonIsEnabled.map(!)
        
        return ToggleTaskStatusTransformer.Outputs(
            toggleTaskStatusButtonIsSelected: toggleTaskStatusButtonIsSelected
            , toggleTaskStatusButtonIsEnabled: toggleTaskStatusButtonIsEnabled
            , toggleTaskStatusButtonActivityIndicatorIsAnimating: toggleTaskStatusButtonActivityIndicatorIsAnimating
        )
    }
}

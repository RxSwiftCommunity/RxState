//
//  TasksTitleTransformer.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxState

final class TasksTitleTransformer: TransformerType {
    struct Inputs: TransformerInputsType {
        let store: StoreType
    }
    
    struct Outputs: TransformerOutputsType {
        let title: Driver<String>
    }
    
    static func transtorm(inputs: TasksTitleTransformer.Inputs) -> TasksTitleTransformer.Outputs {
        
        let title: Driver<String> = inputs.store.tasksState
            .map { (tasksState: Store.TasksState) -> String in
                let loading: Bool = tasksState.addingTask
                    || !tasksState.togglingTaskStatusForTasksWithIds.isEmpty
                    || tasksState.updatingSummaryForTasksWithId != nil
                
                if loading {
                    return "Loading"
                } else {
                    return "Tasks"
                }
            }
        
        let result: TasksTitleTransformer.Outputs = TasksTitleTransformer.Outputs(title: title)
        return result
    }
}

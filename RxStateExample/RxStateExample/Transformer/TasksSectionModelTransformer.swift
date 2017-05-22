//
//  TasksSectionModelTransformer.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxState
import RxDataSources

class TasksSectionModelTransformer {
    struct Inputs {
        let store: StoreType
    }
    
    struct Outputs {
        let sectionModel: Driver<SectionModel>
    }
    
    static func transtorm(inputs: TasksSectionModelTransformer.Inputs) -> TasksSectionModelTransformer.Outputs {
        let sectionModel = inputs.store.tasksState
            .map { (tasksState: TasksStateManager.State) -> [Task] in
                return tasksState.tasks
            }
            .distinctUntilChanged { (lhs: [Task], rhs: [Task]) -> Bool in
                return rhs.count == lhs.count
            }
            .map { (tasks: [Task]) -> SectionModel in
                // Tasks
                let taskTableViewCellViewModels = tasks
                    .map { (task: Task) -> TaskTableViewCellViewModel in
                        let taskTableViewCellViewModel = TaskTableViewCellViewModel(store: inputs.store, taskId: task.id)
                        return taskTableViewCellViewModel
                    }
                
                let items: [SectionItemModelType] = taskTableViewCellViewModels
                
                return SectionModel(items: items)
        }
        
        return TasksSectionModelTransformer.Outputs(sectionModel: sectionModel)
    }
}

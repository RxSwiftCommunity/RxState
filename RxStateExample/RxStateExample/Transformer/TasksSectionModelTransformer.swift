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

final class TasksSectionModelTransformer: TransformerType {
    struct Inputs: TransformerInputsType {
        let store: StoreType
    }
    
    struct Outputs: TransformerOutputsType {
        let sectionModel: Driver<SectionModel>
    }
    
    static func transtorm(inputs: TasksSectionModelTransformer.Inputs) -> TasksSectionModelTransformer.Outputs {
        let sectionModel = inputs.store.tasksState
            .map { (tasksState: Store.TasksState) -> [Task] in
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

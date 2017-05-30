//
//  TasksStateManagement.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation
import RxState


extension Store {
    struct TasksState: SubstateType, CustomDebugStringConvertible, Equatable {
        
        var tasks: [Task]
        var addingTask: Bool
        var togglingTaskStatusForTasksWithIds: [TaskId]
        var updatingSummaryForTasksWithId: (newSummary: String, forTaskWithId: TaskId)?
        
        init() {
            tasks = []
            addingTask = false
            togglingTaskStatusForTasksWithIds = []
        }
        
        static func ==(lhs: Store.TasksState, rhs: Store.TasksState) -> Bool {
            let result = lhs.tasks == rhs.tasks
                && lhs.addingTask == rhs.addingTask
                && lhs.togglingTaskStatusForTasksWithIds == rhs.togglingTaskStatusForTasksWithIds
                && lhs.updatingSummaryForTasksWithId == rhs.updatingSummaryForTasksWithId

            return result
        }
        
        var debugDescription: String {
            let result = "TasksStateManager.state\n"
                .appending("tasks = \(tasks)\n")
                .appending("addingTask = \(addingTask)\n")
                .appending("togglingTaskStatusForTasksWithIds = \(togglingTaskStatusForTasksWithIds)\n")
                .appending("updatingSummaryForTasksWithId = \(String(describing: updatingSummaryForTasksWithId))\n")
            
            return result
        }
    }
    
    enum TasksAction: ActionType {
        case togglingTaskStatus(forTaskWithId: TaskId)
        case toggledTaskStatus(taskStatus: TaskStatus, forTaskWithId: TaskId)
        case addingTask
        case addedTask(task: Task)
        case updatingSummary(newSummary: String, forTaskWithId: TaskId)
        case updatedSummary(newSummary: String, forTaskWithId: TaskId)
    }
    
    static func reduce(state: Store.TasksState, action: Store.TasksAction) -> Store.TasksState {
        var state = state
        switch action {
            
        case let .updatingSummary(summary, id):
            var state = state
            state.updatingSummaryForTasksWithId = (summary, id)
            return state
            
        case let .updatedSummary(summary, id):
            state.updatingSummaryForTasksWithId = nil
            
            guard let index: Array.Index = state.tasks.index(where: { $0.id == id }) else {
                fatalError("Invalid task id")
            }
            state.tasks[index].summary = summary
            
        case let .togglingTaskStatus(id):
            var state = state
            state.togglingTaskStatusForTasksWithIds.append(id)
            return state
            
        case let .toggledTaskStatus(taskStatus, id):
            guard let togglingTaskStatusForTasksWithIdIndex: Array.Index = state.togglingTaskStatusForTasksWithIds.index(of: id) else {
                fatalError("You haven't dispatched `togglingTaskStatus` Action!")
            }
            state.togglingTaskStatusForTasksWithIds.remove(at: togglingTaskStatusForTasksWithIdIndex)
            
            guard let index: Array.Index = state.tasks.index(where: { (task: Task) -> Bool in task.id == id }) else {
                fatalError("Invalid task ID")
            }
            state.tasks[index].status = taskStatus
            
        case .addingTask:
            var state = state
            state.addingTask = true
            return state
            
        case let .addedTask(tasks):
            var state = state
            state.tasks.append(tasks)
            state.addingTask = false
            return state
        }
        
        return state
    }
}

// MARK: - Shortcuts
extension StoreType {
    /// A convenience variable to extract a specific `Task` from the application state
    func task(withId id: TaskId) -> Driver<Task> {
        let task = store.tasksState
            .flatMap { (state: Store.TasksState) -> Driver<Task> in
                guard let task = state.tasks.first(where: { (task: Task) -> Bool in
                    task.id == id
                }) else {
                    return Driver.empty()
                }
                return Driver.of(task)
            }
            .distinctUntilChanged()
        
        return task
    }
    
    /// A convenience variable to extract `Store.TasksState` from the application state
    var tasksState: Driver<Store.TasksState> {
        let tasksState = store.state
            .flatMap { (states: [SubstateType]) -> Driver<Store.TasksState> in
                for state in states {
                    guard let value = state as? Store.TasksState else { continue }
                    return Driver<Store.TasksState>.just(value)
                }
                fatalError("You need to register `Store.TasksState` first")
            }
            .distinctUntilChanged()
        
        return tasksState
    }
}

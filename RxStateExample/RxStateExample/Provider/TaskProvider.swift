//
//  TaskProvider.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation
import RxState

protocol TaskProviderType: ProviderType {
    func add(task: Task) -> Observable<TaskProvider.Action>
    func toggle(taskStatus: TaskStatus, forTaskWithId id: TaskId) -> Observable<TaskProvider.Action>
    func update(summery: String, forTaskWithId id: TaskId) -> Observable<TaskProvider.Action>
}

final class TaskProvider: TaskProviderType {
    
    /// A convenience variable to extract `TaskProvider.State` from the application state
    var taskProviderState: Driver<TaskProvider.State> {
        let taskProviderState = store.state
            .flatMap { (states: [SubstateType]) -> Driver<TaskProvider.State> in
                for state in states {
                    guard let value = state as? TaskProvider.State else { continue }
                    return Driver<TaskProvider.State>.just(value)
                }
                fatalError("You need to register `TaskProvider.State` first")
            }
            .distinctUntilChanged()
        
        return taskProviderState
    }
    
    func add(task: Task) -> Observable<TaskProvider.Action> {
        let observable = Observable<TaskProvider.Action>
            .create { observer -> Disposable in
                observer.on(.next(TaskProvider.Action.addingTask))
                Thread.sleep(forTimeInterval: 2)
                observer.on(.next(TaskProvider.Action.addedTask(task: task)))
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
            .observeOn(MainScheduler.instance)
        
        return observable
    }
    
    func update(summery: String, forTaskWithId id: TaskId) -> Observable<TaskProvider.Action> {
        let observable = Observable<TaskProvider.Action>
            .create { observer -> Disposable in
                observer.on(.next(TaskProvider.Action.updatingSummary(forTaskWithId: id)))
                Thread.sleep(forTimeInterval: 2)
                observer.on(.next(TaskProvider.Action.updatedSummary(summary: summery, forTaskWithId: id)))
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
            .observeOn(MainScheduler.instance)
        
        return observable
    }
    
    func toggle(taskStatus: TaskStatus, forTaskWithId id: TaskId) -> Observable<TaskProvider.Action> {
        
        let observable = Observable<TaskProvider.Action>
            .create { observer -> Disposable in
                observer.on(.next(TaskProvider.Action.togglingTaskStatus(forTaskWithId: id)))
                Thread.sleep(forTimeInterval: 2)
                observer.on(.next(TaskProvider.Action.toggledTaskStatus(taskStatus: taskStatus, forTaskWithId: id)))
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
            .observeOn(MainScheduler.instance)
        
        return observable
    }
}

// State managment
extension TaskProvider {
    struct State: SubstateType, CustomDebugStringConvertible, Equatable {
        var debugDescription: String {
            let result = "TaskProvider.state\n"
                + "tasks = \(tasks)\n"
                + "addingTask = \(addingTask)\n"
                + "togglingTaskStatusForTasksWithIds = \(togglingTaskStatusForTasksWithIds)\n"
                + "updatingSummaryForTasksWithId = \(String(describing: updatingSummaryForTasksWithId))\n"
            
            return result
        }
        
        var tasks: [Task]
        var addingTask: Bool
        var togglingTaskStatusForTasksWithIds: [TaskId]
        var updatingSummaryForTasksWithId: TaskId?
        
        init() {
            tasks = []
            addingTask = false
            togglingTaskStatusForTasksWithIds = []
        }
        
        static func ==(lhs: TaskProvider.State, rhs: TaskProvider.State) -> Bool {
            let result = lhs.tasks == rhs.tasks
                && lhs.addingTask == rhs.addingTask
                && lhs.togglingTaskStatusForTasksWithIds == rhs.togglingTaskStatusForTasksWithIds
                && lhs.updatingSummaryForTasksWithId == rhs.updatingSummaryForTasksWithId
            
            return result
        }
    }
    
    enum Action: ActionType {
        case togglingTaskStatus(forTaskWithId: TaskId)
        case toggledTaskStatus(taskStatus: TaskStatus, forTaskWithId: TaskId)
        case addingTask
        case addedTask(task: Task)
        case updatingSummary(forTaskWithId: TaskId)
        case updatedSummary(summary: String, forTaskWithId: TaskId)
    }
    
    static func reduce(state: TaskProvider.State, sction: TaskProvider.Action) -> TaskProvider.State {
        var state = state
        switch sction {
            
        case let .updatingSummary(id):
            var state = state
            state.updatingSummaryForTasksWithId = id
            return state
            
        case let .updatedSummary(summary, id):
            state.updatingSummaryForTasksWithId = nil
            
            guard let index = state.tasks.index(where: { $0.id == id }) else {
                fatalError("Invalid task ID")
            }
            state.tasks[index].summary = summary
            
        case let .togglingTaskStatus(id):
            var state = state
            state.togglingTaskStatusForTasksWithIds.append(id)
            return state
            
        case let .toggledTaskStatus(taskStatus, id):
            guard let togglingTaskStatusForTasksWithIdIndex = state.togglingTaskStatusForTasksWithIds.index(of: id) else {
                fatalError("I think you haven't dispatched togglingTaskStatus")
            }
            state.togglingTaskStatusForTasksWithIds.remove(at: togglingTaskStatusForTasksWithIdIndex)
            
            guard let index = state.tasks.index(where: { $0.id == id }) else {
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

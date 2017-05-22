//
//  ToggleTaskStatusActionCreator.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

class ToggleTaskStatusActionCreator {
    struct Inputs {
        let store: StoreType
        let taskId: TaskId
    }
    
    static func create(inputs: ToggleTaskStatusActionCreator.Inputs) -> Driver<ActionType> {
        
        return store.task(withId: inputs.taskId)
            .asObservable()
            .flatMap { (task: Task) -> Observable<ActionType> in
                let newStatus = { () -> TaskStatus in
                    switch task.status {
                    case .todo: return .done
                    case .done: return .todo
                    }
                }()
                
                return ToggleTaskStatusActionCreator.toggle(taskStatus: newStatus, forTaskWithId: inputs.taskId)
            }
            .asDriver { (error: Error) -> Driver<ActionType> in
                return Driver.of(ErrorStateManager.Action.addPresentError(presentableError: error))
        }
    }
    
    private static func toggle(taskStatus: TaskStatus, forTaskWithId id: TaskId) -> Observable<ActionType> {
        
        let observable = Observable<ActionType>
            .create { observer -> Disposable in
                observer.on(.next(TasksStateManager.Action.togglingTaskStatus(forTaskWithId: id)))
                Thread.sleep(forTimeInterval: 2)
                observer.on(.next(TasksStateManager.Action.toggledTaskStatus(taskStatus: taskStatus, forTaskWithId: id)))
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
        
        return observable
    }

}

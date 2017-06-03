//
//  ToggleTaskStatusActionCreator.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

final class ToggleTaskStatusActionCreator: ActionCreatorType {
    struct Inputs: ActionCreatorInputsType {
        let store: StoreType
        let taskId: TaskId
    }
    
    static func create(inputs: ToggleTaskStatusActionCreator.Inputs) -> Driver<ActionType> {
        
        return store.task(withId: inputs.taskId)
            .asObservable()
            .take(1)
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
                return Driver.of(Store.ErrorAction.addPresentError(presentableError: error))
        }
    }
    
    private static func toggle(taskStatus: TaskStatus, forTaskWithId id: TaskId) -> Observable<ActionType> {
        
        let observable = Observable<ActionType>
            .create { observer -> Disposable in
                observer.on(.next(Store.TasksAction.togglingTaskStatus(forTaskWithId: id)))
                Thread.sleep(forTimeInterval: 2)
                observer.on(.next(Store.TasksAction.toggleTaskStatus(taskStatus: taskStatus, forTaskWithId: id)))
                observer.on(.completed)
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
        
        return observable
    }

}

//
//  AddTaskActionCreator.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

class AddTaskActionCreator {
    struct Inputs {
        let store: StoreType
        let task: Task
    }
    
    static func create(inputs: AddTaskActionCreator.Inputs) -> Driver<ActionType> {
        return AddTaskActionCreator.requestAdd(task: inputs.task)
            .asDriver { (error: Error) -> Driver<ActionType> in
                return Driver.of(ErrorStateManager.Action.addPresentError(presentableError: error))
        }
    }
    
    private static func requestAdd(task: Task) -> Observable<ActionType> {
        let observable = Observable<ActionType>
            .create { observer -> Disposable in
                observer.on(.next(TasksStateManager.Action.addingTask))
                Thread.sleep(forTimeInterval: 2)
                observer.on(.next(TasksStateManager.Action.addedTask(task: task)))
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
        
        return observable
    }
}

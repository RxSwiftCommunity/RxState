//
//  AddTaskActionCreator.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState

final class AddTaskActionCreator: ActionCreatorType {
    struct Inputs: ActionCreatorInputsType {
        let store: StoreType
        let task: Task
    }
    
    static func create(inputs: AddTaskActionCreator.Inputs) -> Driver<ActionType> {
        let result: Driver<ActionType> = AddTaskActionCreator.requestAdd(task: inputs.task)
            .asDriver { (error: Error) -> Driver<ActionType> in
                return Driver.of(Store.ErrorAction.addPresentError(presentableError: error))
            }
        
        return result
    }
    
    private static func requestAdd(task: Task) -> Observable<ActionType> {
        let observable = Observable<ActionType>
            .create { observer -> Disposable in
                observer.on(.next(Store.TasksAction.addingTask))
                Thread.sleep(forTimeInterval: 2)
                observer.on(.next(Store.TasksAction.addTask(task: task)))
                observer.on(.completed)
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
        
        return observable
    }
}

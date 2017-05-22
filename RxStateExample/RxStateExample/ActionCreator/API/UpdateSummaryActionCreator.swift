//
//  UpdateSummaryActionCreator.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift
import RxState

class UpdateSummaryActionCreator {
    struct Inputs {
        let store: StoreType
        let summary: String
        let taskId: TaskId
    }
    
    static func create(inputs: UpdateSummaryActionCreator.Inputs) -> Driver<ActionType> {
        return UpdateSummaryActionCreator.update(summery: inputs.summary, forTaskWithId: inputs.taskId)
            .asDriver { (error: Error) -> Driver<ActionType> in
                return Driver.of(ErrorStateManager.Action.addPresentError(presentableError: error))
        }
    }
    
    private static func update(summery: String, forTaskWithId id: TaskId) -> Observable<ActionType> {
        let observable = Observable<ActionType>
            .create { observer -> Disposable in
                observer.on(.next(TasksStateManager.Action.updatingSummary(newSummary: summery, forTaskWithId: id)))
                Thread.sleep(forTimeInterval: 2)
                observer.on(.next(TasksStateManager.Action.updatedSummary(newSummary: summery, forTaskWithId: id)))
                return Disposables.create()
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: DispatchQoS.default))
        
        return observable
    }
}
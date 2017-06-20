//
//  TaskTableViewCellViewModel.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift
import RxState

protocol TaskTableViewCellViewModelType: ViewModelType, SectionItemModelType {
    // Going ☝️ to the store
    func set(inputs: TaskTableViewCellViewModel.Inputs) -> Disposable
    // Going 👇 from the store
    func generateOutputs() -> TaskTableViewCellViewModel.Outputs
    
}

struct TaskTableViewCellViewModel: TaskTableViewCellViewModelType {
    let store: StoreType
    let taskId: TaskId
    
    
    struct Inputs: ViewModelInputsType {
        let toggleTaskStatusButtonDidTap: ControlEvent<Void>
        let openTaskButtonDidTap: ControlEvent<Void>
        let summary: ControlProperty<String?>
    }
    
    func set(inputs: TaskTableViewCellViewModel.Inputs) -> Disposable {
        
        let compositeDisposable = CompositeDisposable()
        
        let summaryDisposable = inputs.summary
            .changed
            .asDriver()
            .filterNil()
            .distinctUntilChanged()
            .skip(1)
            .flatMapLatest { (summary: String) -> Driver<ActionType> in
                let updateSummaryActionCreatorInputs = UpdateSummaryActionCreator.Inputs(store: self.store, summary: summary, taskId: self.taskId)
                
                
                let result: Driver<ActionType> = UpdateSummaryActionCreator.create(inputs: updateSummaryActionCreatorInputs)
                return result
                
                /* Writing the return statment without type inferance reduced the compile time to under 50ms.
                 <50
                 let result: Driver<ActionType> = UpdateSummaryActionCreator.create(inputs: updateSummaryActionCreatorInputs)
                 return result
                 
                 >50
                 return UpdateSummaryActionCreator.create(inputs: updateSummaryActionCreatorInputs)
                 */
                
            }
            .drive(onNext: { (action: ActionType) in
                self.store.dispatch(action: action)
            }, onCompleted: nil, onDisposed: nil)
        _ = compositeDisposable.insert(summaryDisposable)
        
        
        let toggleTaskStatusButtonDidTapDisposable = inputs.toggleTaskStatusButtonDidTap
            .asDriver()
            .flatMapLatest { _ -> Driver<ActionType> in
                let toggleTaskStatusActionCreatorInputs = ToggleTaskStatusActionCreator.Inputs(store: self.store, taskId: self.taskId)
                let result: Driver<ActionType> = ToggleTaskStatusActionCreator.create(inputs: toggleTaskStatusActionCreatorInputs)
                return result
            }
            .drive(onNext: { (action: ActionType) in
                self.store.dispatch(action: action)
            }, onCompleted: nil, onDisposed: nil)
        _ = compositeDisposable.insert(toggleTaskStatusButtonDidTapDisposable)
        
        let openTaskButtonDidTapDisposable = inputs.openTaskButtonDidTap
            .asDriver()
            .drive(onNext: { _ in
                let navigateTasksTaskActionCreatorInputs = TasksToTaskCoordinator.Inputs(store: self.store,taskId: self.taskId)
                
                _ = TasksToTaskCoordinator.navigate(inputs: navigateTasksTaskActionCreatorInputs).drive()
            }, onCompleted: nil, onDisposed: nil)

        _ = compositeDisposable.insert(openTaskButtonDidTapDisposable)

        return compositeDisposable
    }
    
    struct Outputs {
        let summary: Driver<String>
        let toggleTaskStatusButtonIsSelected: Driver<Bool>
        let toggleTaskStatusButtonIsEnabled: Driver<Bool>
        let toggleTaskStatusButtonActivityIndicatorIsAnimating: Driver<Bool>
    }
    
    func generateOutputs() -> TaskTableViewCellViewModel.Outputs {
        
        let toggleTaskStatusTransformerInputs = ToggleTaskStatusTransformer.Inputs(store: self.store, taskId: taskId)
        let toggleTaskStatusTransformerOutputs = ToggleTaskStatusTransformer.transtorm(inputs: toggleTaskStatusTransformerInputs)
        let summaryTransformerInputs = SummaryTransformer.Inputs(store: self.store, taskId: taskId)
        let summaryTransformerOutputs = SummaryTransformer.transtorm(inputs: summaryTransformerInputs)
        
        return TaskTableViewCellViewModel.Outputs(
            summary: summaryTransformerOutputs.summary
            , toggleTaskStatusButtonIsSelected: toggleTaskStatusTransformerOutputs.toggleTaskStatusButtonIsSelected
            , toggleTaskStatusButtonIsEnabled: toggleTaskStatusTransformerOutputs.toggleTaskStatusButtonIsEnabled
            , toggleTaskStatusButtonActivityIndicatorIsAnimating: toggleTaskStatusTransformerOutputs.toggleTaskStatusButtonActivityIndicatorIsAnimating
        )
    }
}




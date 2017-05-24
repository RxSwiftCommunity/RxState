//
//  TaskViewControllerViewModel.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa
import RxState
import RxOptional

protocol TaskViewControllerViewModelType: ViewModelType {
    // Going ☝️ to the store
    func set(inputs: TaskViewControllerViewModel.Inputs) -> Disposable
    // Going 👇 from the store
    var outputs: TaskViewControllerViewModel.Outputs { get }
    
}

struct TaskViewControllerViewModel: TaskViewControllerViewModelType {
    let store: StoreType
    let taskId: TaskId
    
    
    struct Inputs {
        let toggleTaskStatusButtonDidTap: ControlEvent<Void>
        let backButtonDidTap: ControlEvent<Void>?
        let summary: ControlProperty<String?>
    }
    
    func set(inputs: TaskViewControllerViewModel.Inputs) -> Disposable {
        
        let compositeDisposable = CompositeDisposable()
        
        let summaryDisposable = inputs.summary
            .changed
            .asDriver()
            .filterNil()
            .distinctUntilChanged()
            .skip(1)
            .flatMapLatest { (summary: String) -> Driver<ActionType> in
                let updateSummaryActionCreatorInputs = UpdateSummaryActionCreator.Inputs(store: self.store, summary: summary, taskId: self.taskId)
                return UpdateSummaryActionCreator.create(inputs: updateSummaryActionCreatorInputs)
            }
            .drive(onNext: { (action: ActionType) in
                self.store.dispatch(action: action)
            }, onCompleted: nil, onDisposed: nil)
        _ = compositeDisposable.insert(summaryDisposable)
        
        
        let toggleTaskStatusButtonDidTapDisposable = inputs.toggleTaskStatusButtonDidTap
            .asDriver()
            .flatMapLatest { _ -> Driver<ActionType> in
                let toggleTaskStatusActionCreatorInputs = ToggleTaskStatusActionCreator.Inputs(store: self.store, taskId: self.taskId)
                return ToggleTaskStatusActionCreator.create(inputs: toggleTaskStatusActionCreatorInputs)
            }
            .drive(onNext: { (action: ActionType) in
                self.store.dispatch(action: action)
            }, onCompleted: nil, onDisposed: nil)
        _ = compositeDisposable.insert(toggleTaskStatusButtonDidTapDisposable)
        
        
        if let backButtonDidTap = inputs.backButtonDidTap {
            let backButtonDidTapDisposable = backButtonDidTap
                .asDriver()
                .drive(onNext: { _ in
                    let navigateTaskToTaskActionCreatorInputs = NavigateTaskToTasksActionCreator.Inputs(store: self.store)
                    
                    _ = NavigateTaskToTasksActionCreator.navigate(inputs: navigateTaskToTaskActionCreatorInputs).drive()
                }, onCompleted: nil, onDisposed: nil)
            _ = compositeDisposable.insert(backButtonDidTapDisposable)
        }
        return compositeDisposable
    }
    
    struct Outputs {
        let summary: Driver<String>
        let toggleTaskStatusButtonIsSelected: Driver<Bool>
        let toggleTaskStatusButtonIsEnabled: Driver<Bool>
        let toggleTaskStatusButtonActivityIndicatorIsAnimating: Driver<Bool>
    }
    
    var outputs: TaskViewControllerViewModel.Outputs {
        
        let toggleTaskStatusTransformerInputs = ToggleTaskStatusTransformer.Inputs(store: self.store, taskId: taskId)
        let toggleTaskStatusTransformerOutputs = ToggleTaskStatusTransformer.transtorm(inputs: toggleTaskStatusTransformerInputs)
        let summaryTransformerInputs = SummaryTransformer.Inputs(store: self.store, taskId: taskId)
        let summaryTransformerOutputs = SummaryTransformer.transtorm(inputs: summaryTransformerInputs)
        
        return TaskViewControllerViewModel.Outputs(
            summary: summaryTransformerOutputs.summary
            , toggleTaskStatusButtonIsSelected: toggleTaskStatusTransformerOutputs.toggleTaskStatusButtonIsSelected
            , toggleTaskStatusButtonIsEnabled: toggleTaskStatusTransformerOutputs.toggleTaskStatusButtonIsEnabled
            , toggleTaskStatusButtonActivityIndicatorIsAnimating: toggleTaskStatusTransformerOutputs.toggleTaskStatusButtonActivityIndicatorIsAnimating
        )
    }
}

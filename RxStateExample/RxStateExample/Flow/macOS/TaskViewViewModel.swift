//
//  TaskViewViewModel.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Cocoa
import RxSwift
import RxCocoa
import RxState
import RxOptional

protocol TaskViewViewModelType: ViewModelType {
    // Going ☝️ to the store
    func set(inputs: TaskViewViewModel.Inputs) -> Disposable
    // Going 👇 from the store
    var outputs: TaskViewViewModel.Outputs { get }
}

struct TaskViewViewModel: TaskViewViewModelType {
    let store: StoreType
    let taskId: TaskId
    
    struct Inputs: ViewModelInputsType {
        let toggleTaskStatusButtonDidTap: ControlEvent<Void>
        let summary: ControlProperty<String?>
    }
    
    func set(inputs: TaskViewViewModel.Inputs) -> Disposable {
        
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
        
        return compositeDisposable
    }
    
    struct Outputs: ViewModelOutputsType {
        let summary: Driver<String>
        let toggleTaskStatusButtonIsSelected: Driver<Int>
    }
    
    var outputs: TaskViewViewModel.Outputs {
        
        let toggleTaskStatusTransformerInputs = ToggleTaskStatusTransformer.Inputs(store: self.store, taskId: taskId)
        let toggleTaskStatusTransformerOutputs = ToggleTaskStatusTransformer.transtorm(inputs: toggleTaskStatusTransformerInputs)
        let summaryTransformerInputs = SummaryTransformer.Inputs(store: self.store, taskId: taskId)
        let summaryTransformerOutputs = SummaryTransformer.transtorm(inputs: summaryTransformerInputs)
        
        let toggleTaskStatusButtonIsSelected = toggleTaskStatusTransformerOutputs.toggleTaskStatusButtonIsSelected.map { (selected: Bool) -> Int in
            if selected { return 1 }
            return 0
        }
        
        return TaskViewViewModel.Outputs(
            summary: summaryTransformerOutputs.summary
            , toggleTaskStatusButtonIsSelected: toggleTaskStatusButtonIsSelected
        )
    }
}

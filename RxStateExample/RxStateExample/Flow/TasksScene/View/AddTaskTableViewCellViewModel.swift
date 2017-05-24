//
//  AddTaskTableViewCellViewModel.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift
import RxCocoa
import RxState


protocol AddTaskTableViewCellViewModelType: ViewModelType {
    // Going ☝️ to the store
    func set(inputs: AddTaskTableViewCellViewModel.Inputs) -> Disposable
    // Going 👇 from the store
    var outputs: AddTaskTableViewCellViewModel.Outputs { get }
}

struct AddTaskTableViewCellViewModel: AddTaskTableViewCellViewModelType {
    let store: StoreType

    
    struct Inputs {
        let addTaskStatusButtonDidTap: ControlEvent<Void>
    }
    
    func set(inputs: AddTaskTableViewCellViewModel.Inputs) -> Disposable {
        
        let result: Disposable = inputs.addTaskStatusButtonDidTap
            .asDriver()
            .flatMapLatest { (_) -> Driver<ActionType> in
                let task = Task(summary: "Your new task :)", status: TaskStatus.todo)

                let addTaskActionCreatorInputs = AddTaskActionCreator.Inputs(store: self.store, task: task)
                return AddTaskActionCreator.create(inputs: addTaskActionCreatorInputs)
            }
            .drive(onNext: { (action: ActionType) in
                self.store.dispatch(action: action)
            }, onCompleted: nil, onDisposed: nil)
        
        return result
    }
    
    struct Outputs {
        let addTaskButtonActivityIndicatorIsAnimating: Driver<Bool>
    }

    var outputs: AddTaskTableViewCellViewModel.Outputs {
        
        let addTaskButtonActivityIndicatorIsAnimatingInputs = AddTaskButtonActivityIndicatorIsAnimatingTransformer.Inputs(store: store)
        let addTaskButtonActivityIndicatorIsAnimatingOutputs = AddTaskButtonActivityIndicatorIsAnimatingTransformer.transtorm(inputs: addTaskButtonActivityIndicatorIsAnimatingInputs)
        
        return AddTaskTableViewCellViewModel.Outputs(addTaskButtonActivityIndicatorIsAnimating: addTaskButtonActivityIndicatorIsAnimatingOutputs.addTaskButtonActivityIndicatorIsAnimating)
    }
}

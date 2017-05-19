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

struct AddTaskTableViewCellViewModelInputs: ViewModelInputsType {
    let addTaskStatusButtonDidTap: ControlEvent<Void>
    let disposeBag: DisposeBag
}

struct AddTaskTableViewCellViewModelOutputs: ViewModelOutputsType {
    let addTaskButtonActivityIndicatorISAnimating: Driver<Bool>
}

protocol AddTaskTableViewCellViewModelType: ViewModelType {
    func transform(inputs: AddTaskTableViewCellViewModelInputs) -> AddTaskTableViewCellViewModelOutputs
}

struct AddTaskTableViewCellViewModel: AddTaskTableViewCellViewModelType {
    let id = Foundation.UUID().uuidString

    fileprivate let taskProvider: TaskProvider
    fileprivate let store: StoreType
    
    init(
        store: StoreType
        , taskProvider: TaskProvider
        ) {
        self.store = store
        self.taskProvider = taskProvider
    }

    func transform(inputs: AddTaskTableViewCellViewModelInputs) -> AddTaskTableViewCellViewModelOutputs {

        inputs.addTaskStatusButtonDidTap
            .flatMapLatest { _ -> Observable<TaskProvider.Action> in
                self.taskProvider.add(task: Task(summary: "Your new task :)", status: TaskStatus.todo))
            }
            .subscribe(
                onNext: { (action: TaskProvider.Action) in
                    self.store.dispatch(action: action)
                }
                , onError: nil
                , onCompleted: nil
                , onDisposed: nil
            )
            .disposed(by: inputs.disposeBag)

        let addTaskButtonActivityIndicatorISAnimating = taskProvider.taskProviderState
            .map { (taskProviderState: TaskProvider.State) -> Bool in
                return taskProviderState.addingTask
        }

        return AddTaskTableViewCellViewModelOutputs(addTaskButtonActivityIndicatorISAnimating: addTaskButtonActivityIndicatorISAnimating)
    }

}

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
}

struct AddTaskTableViewCellViewModelOutputs: ViewModelOutputsType {
}

protocol AddTaskTableViewCellViewModelType: ViewModelType {
    func transform(inputs: AddTaskTableViewCellViewModelInputs) -> AddTaskTableViewCellViewModelOutputs
}

struct AddTaskTableViewCellViewModel: AddTaskTableViewCellViewModelType {
    var disposeBag = DisposeBag()
    let id = Foundation.UUID().uuidString

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
            .addDisposableTo(disposeBag)

        return AddTaskTableViewCellViewModelOutputs()
    }

    let taskProvider: TaskProvider
    let store: StoreType

    init(
        store: StoreType
        , taskProvider: TaskProvider
    ) {
        self.store = store
        self.taskProvider = taskProvider
    }
}

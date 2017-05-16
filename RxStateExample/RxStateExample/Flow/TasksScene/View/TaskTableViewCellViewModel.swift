//
//  TaskTableViewCellViewModel.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift
import RxState

struct TaskTableViewCellViewModelInputs: ViewModelInputsType {
    let toggleTaskStatusButtonDidTap: ControlEvent<Void>
    let summary: ControlProperty<String?>
}

struct TaskTableViewCellViewModelOutputs: ViewModelOutputsType {
    let summary: Driver<String>
    let isSelected: Driver<Bool>
    let toggleTaskStatusButtonIsEnabled: Driver<Bool>
}

protocol TaskTableViewCellViewModelType: ViewModelType {
    func transform(inputs: TaskTableViewCellViewModelInputs) -> TaskTableViewCellViewModelOutputs
}

struct TaskTableViewCellViewModel: TaskTableViewCellViewModelType {
    var disposeBag = DisposeBag()
    let id = Foundation.UUID().uuidString

    func transform(inputs: TaskTableViewCellViewModelInputs) -> TaskTableViewCellViewModelOutputs {

        let taskProviderState = store.state
            .flatMap { (states: [SubstateType]) -> Driver<TaskProvider.State> in
                for state in states {
                    guard let value = state as? TaskProvider.State else { continue }
                    return Driver<TaskProvider.State>.just(value)
                }
                fatalError("You need to register `TaskProvider.State` first")
            }

        let task = taskProviderState
            .flatMap { (state: TaskProvider.State) -> Driver<Task> in
                guard let task = state.tasks.first(where: { (task: Task) -> Bool in
                    task.id == self.taskId
                }) else {
                    return Driver.empty()
                }
                return Driver.of(task)
            }
            .distinctUntilChanged()

        inputs.toggleTaskStatusButtonDidTap
            .withLatestFrom(task)
            .flatMapLatest { (task: Task) -> Observable<TaskProvider.Action> in
                let newStatus = { () -> TaskStatus in
                    switch task.status {
                    case .todo: return .done
                    case .done: return .todo
                    }
                }()
                return self.taskProvider.toggle(taskStatus: newStatus, forTaskWithId: self.taskId)
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

        inputs.summary
            .orEmpty
            .skip(1) // The first value is the TextField initial text
            .throttle(3, scheduler: MainScheduler.instance)
            .flatMapLatest { (summary: String) -> Observable<TaskProvider.Action> in
                return self.taskProvider.update(summery: summary, forTaskWithId: self.taskId)
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

        let summary = task
            .map { (task: Task) -> String in task.summary }

        let isSelected = task
            .map { (task: Task) -> Bool in
                return task.status == .done
            }

        let togglingTaskStatusActivityIndicatorIsHidden = taskProviderState
            .map { (taskProviderState: TaskProvider.State) -> Bool in
                return !taskProviderState.togglingTaskStatusForTasksWithIds.contains(self.taskId)
            }

        let toggleTaskStatusButtonIsEnabled = togglingTaskStatusActivityIndicatorIsHidden

        return TaskTableViewCellViewModelOutputs(summary: summary, isSelected: isSelected, toggleTaskStatusButtonIsEnabled: toggleTaskStatusButtonIsEnabled)
    }

    let taskProvider: TaskProvider
    let store: StoreType
    let taskId: TaskId

    init(
        store: StoreType
        , taskId: TaskId
        , taskProvider: TaskProvider
    ) {
        self.taskId = taskId
        self.store = store
        self.taskProvider = taskProvider
    }
}

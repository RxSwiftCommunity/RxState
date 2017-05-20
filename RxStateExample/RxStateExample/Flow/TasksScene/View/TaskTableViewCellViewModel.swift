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
    let openTaskButtonDidTap: ControlEvent<Void>
    let summary: ControlProperty<String?>
    let disposeBag: DisposeBag
}

struct TaskTableViewCellViewModelOutputs: ViewModelOutputsType {
    let summary: Driver<String>
    let toggleTaskStatusButtonIsSelected: Driver<Bool>
    let toggleTaskStatusButtonIsEnabled: Driver<Bool>
    let toggleTaskStatusButtonActivityIndicatorISAnimating: Driver<Bool>
}

protocol TaskTableViewCellViewModelType: ViewModelType {
    func transform(inputs: TaskTableViewCellViewModelInputs) -> TaskTableViewCellViewModelOutputs
}

struct TaskTableViewCellViewModel: TaskTableViewCellViewModelType {
    let id = Foundation.UUID().uuidString

    fileprivate let taskProvider: TaskProvider
    fileprivate let store: StoreType
    fileprivate let taskId: TaskId
    fileprivate let coordinatingService: CoordinatingService
    
    init(
        store: StoreType
        , taskId: TaskId
        , taskProvider: TaskProvider
        , coordinatingService: CoordinatingService
        ) {
        self.coordinatingService = coordinatingService
        self.taskId = taskId
        self.taskProvider = taskProvider
        self.store = store
    }

    func transform(inputs: TaskTableViewCellViewModelInputs) -> TaskTableViewCellViewModelOutputs {

        // Setup needed properties
        let task = taskProvider.taskProviderState
            .flatMap { (state: TaskProvider.State) -> Driver<Task> in
                guard let task = state.tasks.first(where: { (task: Task) -> Bool in
                    task.id == self.taskId
                }) else {
                    return Driver.empty()
                }
                return Driver.of(task)
            }
            .distinctUntilChanged()

        // Handle input
        
        inputs.openTaskButtonDidTap
            .withLatestFrom(task)
            .subscribe(
                onNext: { (task: Task) in
                    self.store.dispatch(action: CoordinatingService.Action.transissionToRoute(route: Route.task(id: task.id)))
            }
                , onError: nil, onCompleted: nil, onDisposed: nil
            )
            .disposed(by: inputs.disposeBag)

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
            .disposed(by: inputs.disposeBag)

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
            .disposed(by: inputs.disposeBag)

        // Setup output
        let summary = task
            .map { (task: Task) -> String in task.summary }

        let toggleTaskStatusButtonIsSelected = task
            .map { (task: Task) -> Bool in
                return task.status == .done
            }

        let toggleTaskStatusButtonIsEnabled = taskProvider.taskProviderState
            .map { (taskProviderState: TaskProvider.State) -> Bool in
                return !taskProviderState.togglingTaskStatusForTasksWithIds.contains(self.taskId)
        }
        
        let toggleTaskStatusButtonActivityIndicatorISAnimating = toggleTaskStatusButtonIsEnabled.map(!)

        return TaskTableViewCellViewModelOutputs(
            summary: summary
            , toggleTaskStatusButtonIsSelected: toggleTaskStatusButtonIsSelected
            , toggleTaskStatusButtonIsEnabled: toggleTaskStatusButtonIsEnabled
            , toggleTaskStatusButtonActivityIndicatorISAnimating: toggleTaskStatusButtonActivityIndicatorISAnimating
        )
    }
}

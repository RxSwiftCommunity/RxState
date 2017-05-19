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

struct TaskViewControllerViewModelInputs: ViewModelInputsType {
    let toggleTaskStatusButtonDidTap: ControlEvent<Void>
    let summary: ControlProperty<String?>
    let backButtonDidTap: ControlEvent<Void>?
}

struct TaskViewControllerViewModelOutputs: ViewModelOutputsType {
    let summary: Driver<String>
    let toggleTaskStatusButtonIsSelected: Driver<Bool>
    let toggleTaskStatusButtonIsEnabled: Driver<Bool>
    let toggleTaskStatusButtonActivityIndicatorISAnimating: Driver<Bool>
}

protocol TaskViewControllerViewModelType: ViewModelType {
    func transform(inputs: TaskViewControllerViewModelInputs) -> TaskViewControllerViewModelOutputs
}

struct TaskViewControllerViewModel: TaskViewControllerViewModelType {
    var disposeBag = DisposeBag()
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

    func transform(inputs: TaskViewControllerViewModelInputs) -> TaskViewControllerViewModelOutputs {

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
            .disposed(by: disposeBag)
        
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
            .disposed(by: disposeBag)
        
        inputs.backButtonDidTap?
            .flatMapLatest { (_) -> Observable<CoordinatingService.Action> in
                return self.coordinatingService.transission(toRoute: Route.tasks)
            }
            .subscribe(
                onNext: { (action: CoordinatingService.Action)in
                    self.store.dispatch(action: action)
                }
                , onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        // Setup output
        let summary = task
            .map { (task: Task) -> String in task.summary }
        
        let toggleTaskStatusButtonIsSelected = task
            .map { (task: Task) -> Bool in
                return task.status == .done
        }
        
        let toggleTaskStatusButtonIsEnabled = taskProvider.taskProviderState
            .debug("taskProviderState")
            .map { (taskProviderState: TaskProvider.State) -> Bool in
                return !taskProviderState.togglingTaskStatusForTasksWithIds.contains(self.taskId)
        }

        
        let toggleTaskStatusButtonActivityIndicatorISAnimating = toggleTaskStatusButtonIsEnabled.map(!)

        return TaskViewControllerViewModelOutputs(
            summary: summary
            , toggleTaskStatusButtonIsSelected: toggleTaskStatusButtonIsSelected
            , toggleTaskStatusButtonIsEnabled: toggleTaskStatusButtonIsEnabled
            , toggleTaskStatusButtonActivityIndicatorISAnimating: toggleTaskStatusButtonActivityIndicatorISAnimating
        )
    }
}

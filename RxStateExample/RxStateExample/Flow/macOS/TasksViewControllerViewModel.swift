//
//  TasksViewControllerViewModel.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//


import Cocoa
import RxSwift
import RxCocoa
import RxState
import RxOptional

protocol TasksViewControllerViewModelType: ViewModelType, NSTableViewDataSource, NSTableViewDelegate {
    // Going ☝️ to the store
    func set(inputs: TasksViewControllerViewModel.Inputs) -> Disposable
    // Going 👇 from the store
    var outputs: TasksViewControllerViewModel.Outputs { get }
}

class TasksViewControllerViewModel: NSObject, TasksViewControllerViewModelType {
    let store: StoreType
    let tasks = Variable([Task]())

    init(store: StoreType) {
        self.store = store
        super.init()
    }
    
    struct Inputs: ViewModelInputsType {
        let addTaskButtonDidTap: ControlEvent<Void>
    }
    
    func set(inputs: TasksViewControllerViewModel.Inputs) -> Disposable {
        let compositeDisposable = CompositeDisposable()

        let tasksDisposable = store.tasksState
            .map { (tasksState: Store.TasksState) -> [Task] in
                return tasksState.tasks
            }
            .drive(tasks)
        _ = compositeDisposable.insert(tasksDisposable)

        let addTaskDisposable: Disposable = inputs.addTaskButtonDidTap
            .asDriver()
            .flatMapLatest { (_) -> Driver<ActionType> in
                let task = Task(summary: "Your new task :)", status: TaskStatus.todo)
                
                let addTaskActionCreatorInputs = AddTaskActionCreator.Inputs(store: self.store, task: task)
                return AddTaskActionCreator.create(inputs: addTaskActionCreatorInputs)
            }
            .drive(onNext: { (action: ActionType) in
                self.store.dispatch(action: action)
            }, onCompleted: nil, onDisposed: nil)
        _ = compositeDisposable.insert(addTaskDisposable)

        return compositeDisposable
    }
    
    struct Outputs: ViewModelOutputsType {
        let reloadTasksTableViewSignal: Driver<Void>
        let title: Driver<String>
    }
    
    var outputs: TasksViewControllerViewModel.Outputs {
        let reloadTasksTableViewSignal = tasks
            .asDriver()
            .distinctUntilChanged({ (lhsTasks: [Task], rhsTasks: [Task]) -> Bool in
                lhsTasks.count == rhsTasks.count
            })
            .map { (tasks: [Task]) -> Void in return () }
        
        let title = TasksTitleTransformer.transtorm(inputs: TasksTitleTransformer.Inputs(store: self.store)).title

//        let toggleTaskStatusTransformerInputs = ToggleTaskStatusTransformer.Inputs(store: self.store, taskId: taskId.asDriver())
//        let toggleTaskStatusTransformerOutputs = ToggleTaskStatusTransformer.transtorm(inputs: toggleTaskStatusTransformerInputs)
//        let summaryTransformerInputs = SummaryTransformer.Inputs(store: self.store, taskId: taskId.asDriver())
//        let summaryTransformerOutputs = SummaryTransformer.transtorm(inputs: summaryTransformerInputs)
//        
//        let toggleTaskStatusButtonIsSelected = toggleTaskStatusTransformerOutputs.toggleTaskStatusButtonIsSelected.map { (selected: Bool) -> Int in
//            if selected { return 1 }
//            return 0
//        }
        
        return TasksViewControllerViewModel.Outputs(reloadTasksTableViewSignal: reloadTasksTableViewSignal
            , title: title)
    }
    
}

extension TasksViewControllerViewModel {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tasks.value.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let taskId = tasks.value[row].id
        let taskViewViewModel = TaskViewViewModel(store: store, taskId: taskId)
        let taskView = TaskView.build(withViewModel: taskViewViewModel)
        return taskView
    }    
}

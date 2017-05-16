//
//  TasksViewControllerViewModel.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxState

struct TasksViewControllerViewModelInputs: ViewModelInputsType {}

struct TasksViewControllerViewModelOutputs: ViewModelOutputsType {
    let sectionsModels: Driver<[TasksTableViewModelSectionModel]>
    let dataSource: RxTableViewSectionedReloadDataSource<TasksTableViewModelSectionModel>
    let title: Driver<String>
}

protocol TasksViewControllerViewModelType: ViewModelType {
    func transform(inputs: TasksViewControllerViewModelInputs) -> TasksViewControllerViewModelOutputs
}

struct TasksViewControllerViewModel: TasksViewControllerViewModelType {
    var disposeBag = DisposeBag()
    let id = Foundation.UUID().uuidString

    // Mark: - Dependancy
    let taskProvider: TaskProvider

    init(
        taskProvider: TaskProvider
    ) {
        self.taskProvider = taskProvider
    }

    func transform(inputs _: TasksViewControllerViewModelInputs) -> TasksViewControllerViewModelOutputs {

        let taskProviderState = store.state
            .flatMap { (states: [SubstateType]) -> Driver<TaskProvider.State> in
                for state in states {
                    guard let value = state as? TaskProvider.State else { continue }
                    return Driver<TaskProvider.State>.just(value)
                }
                fatalError("You need to register `TaskProvider.State` first")
            }

        let sectionsModels = taskProviderState
            .map { (taskProviderState: TaskProvider.State) -> [Task] in
                return taskProviderState.tasks
            }
            .distinctUntilChanged { (lhs: [Task], rhs: [Task]) -> Bool in
                return rhs == lhs
            }
            .map { (tasks: [Task]) -> [TasksTableViewModelSectionModel] in
                // Tasks
                let tasksTableViewModelSectionItems = tasks
                    .map { (task: Task) -> TasksTableViewModelSectionItem in
                        let vm = TaskTableViewCellViewModel(store: store, taskId: task.id, taskProvider: self.taskProvider)
                        return TasksTableViewModelSectionItem.taskTableViewModelSectionItem(viewModel: vm)
                    }
                    .reduce([], { (result: [TasksTableViewModelSectionItem], tasksTableViewModelSectionItem: TasksTableViewModelSectionItem) -> [TasksTableViewModelSectionItem] in
                        var result = result
                        result.append(tasksTableViewModelSectionItem)
                        return result
                    })

                // Adding a task
                let vm = AddTaskTableViewCellViewModel(store: store, taskProvider: self.taskProvider)
                let addTaskTableViewModelSectionItem = TasksTableViewModelSectionItem.addTaskTableViewModelSectionItem(viewModel: vm)

                let items: [TasksTableViewModelSectionItem] = tasksTableViewModelSectionItems + [addTaskTableViewModelSectionItem]

                return [TasksTableViewModelSectionModel.taskTableViewModelSectionItem(items: items)]
            }

        let dataSource = RxTableViewSectionedReloadDataSource<TasksTableViewModelSectionModel>()

        skinTableViewDataSource(dataSource)

        let title = taskProviderState
            .map { (taskProviderState: TaskProvider.State) -> Bool in
                taskProviderState.addingTask || !taskProviderState.togglingTaskStatusForTasksWithIds.isEmpty
            }
            .map { (loading: Bool) -> String in
                if loading {
                    return "Loading"
                } else {
                    return "Tasks"
                }
            }

        return TasksViewControllerViewModelOutputs(sectionsModels: sectionsModels, dataSource: dataSource, title: title)
    }
}

fileprivate func skinTableViewDataSource(_ dataSource: RxTableViewSectionedReloadDataSource<TasksTableViewModelSectionModel>) {
    dataSource.configureCell = { _, tableView, _, item in
        switch item {
        case let .taskTableViewModelSectionItem(viewModel):
            let cell = TaskTableViewCell.build(withViewModel: viewModel, forTableView: tableView)
            return cell

        case let .addTaskTableViewModelSectionItem(viewModel):
            let cell = AddTaskTableViewCell.build(withViewModel: viewModel, forTableView: tableView)
            return cell
        }
    }
}

enum TasksTableViewModelSectionModel {
    case taskTableViewModelSectionItem(items: [TasksTableViewModelSectionItem])
}

extension TasksTableViewModelSectionModel: SectionModelType {
    typealias Item = TasksTableViewModelSectionItem

    var items: [TasksTableViewModelSectionItem] {
        switch self {
        case let .taskTableViewModelSectionItem(items: items):
            return items
        }
    }

    init(original: TasksTableViewModelSectionModel, items: [Item]) {
        switch original {
        case .taskTableViewModelSectionItem(items: _):
            self = .taskTableViewModelSectionItem(items: items)
        }
    }
}

enum TasksTableViewModelSectionItem {
    case taskTableViewModelSectionItem(viewModel: TaskTableViewCellViewModel)
    case addTaskTableViewModelSectionItem(viewModel: AddTaskTableViewCellViewModel)
}

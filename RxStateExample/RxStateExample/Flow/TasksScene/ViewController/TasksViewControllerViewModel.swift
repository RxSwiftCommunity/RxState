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
    fileprivate let taskProvider: TaskProvider
    fileprivate let coordinatingService: CoordinatingService
    fileprivate let store: StoreType
    
    init(
        store: StoreType
        , taskProvider: TaskProvider
        , coordinatingService: CoordinatingService
    ) {
        self.store = store
        self.coordinatingService = coordinatingService
        self.taskProvider = taskProvider
    }

    func transform(inputs _: TasksViewControllerViewModelInputs) -> TasksViewControllerViewModelOutputs {

        let sectionsModels = taskProvider.taskProviderState
            .map { (taskProviderState: TaskProvider.State) -> [Task] in
                return taskProviderState.tasks
            }
            .distinctUntilChanged { (lhs: [Task], rhs: [Task]) -> Bool in
                return rhs.count == lhs.count
            }
            .map { (tasks: [Task]) -> [TasksTableViewModelSectionModel] in
                // Tasks
                let tasksTableViewModelSectionItems = tasks
                    .map { (task: Task) -> TasksTableViewModelSectionItem in
                        let vm = TaskTableViewCellViewModel(store: self.store, taskId: task.id, taskProvider: self.taskProvider, coordinatingService: self.coordinatingService)
                        return TasksTableViewModelSectionItem.taskTableViewModelSectionItem(viewModel: vm)
                    }
                    .reduce([], { (result: [TasksTableViewModelSectionItem], tasksTableViewModelSectionItem: TasksTableViewModelSectionItem) -> [TasksTableViewModelSectionItem] in
                        var result = result
                        result.append(tasksTableViewModelSectionItem)
                        return result
                    })

                // Adding a task
                let vm = AddTaskTableViewCellViewModel(store: self.store, taskProvider: self.taskProvider)
                let addTaskTableViewModelSectionItem = TasksTableViewModelSectionItem.addTaskTableViewModelSectionItem(viewModel: vm)

                let items: [TasksTableViewModelSectionItem] = tasksTableViewModelSectionItems + [addTaskTableViewModelSectionItem]

                return [TasksTableViewModelSectionModel.taskTableViewModelSectionItem(items: items)]
            }

        let dataSource = RxTableViewSectionedReloadDataSource<TasksTableViewModelSectionModel>()

        skinTableViewDataSource(dataSource)

        let title = taskProvider.taskProviderState
            .map { (taskProviderState: TaskProvider.State) -> Bool in
                taskProviderState.addingTask
                    || !taskProviderState.togglingTaskStatusForTasksWithIds.isEmpty
                    || taskProviderState.updatingSummaryForTasksWithId != nil
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

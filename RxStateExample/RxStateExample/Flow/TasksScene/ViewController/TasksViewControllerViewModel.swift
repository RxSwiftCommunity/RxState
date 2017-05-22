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


protocol TasksViewControllerViewModelType: ViewModelType {
    // Going ☝️ to the store
    func bind(inputs: TasksViewControllerViewModel.Inputs) -> Disposable
    // Going 👇 from the store
    var outputs: TasksViewControllerViewModel.Outputs { get }
    
}

struct TasksViewControllerViewModel: TasksViewControllerViewModelType {
    let store: StoreType
    
    
    struct Inputs {
    }
    
    func bind(inputs: TasksViewControllerViewModel.Inputs) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        return compositeDisposable
    }
    
    struct Outputs {
        let sectionsModels: Driver<[SectionModel]>
        let dataSource: RxTableViewSectionedReloadDataSource<SectionModel>
        let title: Driver<String>
    }
    
    var outputs: TasksViewControllerViewModel.Outputs {

        let tasksSectionModel = TasksSectionModelTransformer.transtorm(inputs: TasksSectionModelTransformer.Inputs(store: self.store)).sectionModel
        let addTaskSectionItemModel: SectionItemModelType = AddTaskTableViewCellViewModel(store: self.store)
        let addTaskSectionModel = Driver.of(SectionModel(items: [addTaskSectionItemModel]))
        let sectionsModels = Driver.combineLatest([tasksSectionModel, addTaskSectionModel])
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>()
        skinTableViewDataSource(dataSource)
        
        let title = TasksTitleTransformer.transtorm(inputs: TasksTitleTransformer.Inputs(store: self.store)).title
        
        return TasksViewControllerViewModel.Outputs(
            sectionsModels: sectionsModels
            , dataSource: dataSource
            , title: title
        )
    }
    
    fileprivate func skinTableViewDataSource(_ dataSource: RxTableViewSectionedReloadDataSource<SectionModel>) {
        dataSource.configureCell = { _, tableView, _, item in
            switch item {
            case let taskTableViewCellViewModel as TaskTableViewCellViewModel:
                let cell = TaskTableViewCell.build(withViewModel: taskTableViewCellViewModel, forTableView: tableView)
                return cell
                
            case let addTaskTableViewCellViewModel as AddTaskTableViewCellViewModel:
                let cell = AddTaskTableViewCell.build(withViewModel: addTaskTableViewCellViewModel, forTableView: tableView)
                return cell
                
            default:
                fatalError("This item is not supported in the table view")
            }
        }
    }
}

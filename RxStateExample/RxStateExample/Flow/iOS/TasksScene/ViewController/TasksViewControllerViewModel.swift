//
//  TasksViewControllerViewModel.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxState


protocol TasksViewControllerViewModelType: ViewModelType, SectionItemModelType {
    // Going ☝️ to the store
    func set(inputs: TasksViewControllerViewModel.Inputs) -> Disposable
    
    // Going 👇 from the store
    func generateOutputs() -> TasksViewControllerViewModel.Outputs
    
}

struct TasksViewControllerViewModel: TasksViewControllerViewModelType {
    let store: StoreType
    
    
    struct Inputs: ViewModelInputsType {
    }
    
    func set(inputs: TasksViewControllerViewModel.Inputs) -> Disposable {
        let compositeDisposable = CompositeDisposable()
        return compositeDisposable
    }
    
    struct Outputs: ViewModelOutputsType {
        let sectionsModels: Driver<[SectionModel]>
        let dataSource: RxTableViewSectionedReloadDataSource<SectionModel>
        let title: Driver<String>
    }
    
    func generateOutputs() -> TasksViewControllerViewModel.Outputs {

        let tasksSectionModel = TasksSectionModelTransformer.transtorm(inputs: TasksSectionModelTransformer.Inputs(store: self.store)).sectionModel
        let addTaskSectionItemModel: SectionItemModelType = AddTaskTableViewCellViewModel(store: self.store)
        let addTaskSectionModel = Driver.of(SectionModel(items: [addTaskSectionItemModel]))
        let sectionsModels = Driver.combineLatest([tasksSectionModel, addTaskSectionModel])
        
//        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(configureCell: (TableViewSectionedDataSource<SectionModel>, UITableView, IndexPath, SectionModel.Item) -> UITableViewCell)
//
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
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
        })
        
        let title = TasksTitleTransformer.transtorm(inputs: TasksTitleTransformer.Inputs(store: self.store)).title
        
        return TasksViewControllerViewModel.Outputs(
            sectionsModels: sectionsModels
            , dataSource: dataSource
            , title: title
        )
    }
    
}

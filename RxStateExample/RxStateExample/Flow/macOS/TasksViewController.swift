//
//  ViewController.swift
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

class TasksViewController: ViewController {
    
    // MARK: - ViewModel
    fileprivate var viewModel: TasksViewControllerViewModelType!
    
    // MARK: - @IBOutlet
    
    @IBOutlet private weak var tasksTableView: NSTableView!
    @IBOutlet private weak var addTaskButton: NSButton!
    @IBOutlet private weak var titleTextField: NSTextField!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Should be injected link in the iOS app! For simplecity sake.
        self.viewModel = TasksViewControllerViewModel(store: store)
        tasksTableView.dataSource = viewModel
        tasksTableView.delegate = viewModel
        setViewModelInputs()
        bindViewModelOutputs()
    }
    
    
    private func setViewModelInputs() {
        let viewModelInputs = TasksViewControllerViewModel.Inputs(addTaskButtonDidTap: addTaskButton.rx.tap)
        
        viewModel.set(inputs: viewModelInputs)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModelOutputs() {
        viewModel.outputs.title
            .drive(titleTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.reloadTasksTableViewSignal
            .drive(onNext: {
                self.tasksTableView.reloadData()
            }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}

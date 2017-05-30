//
//  TasksViewController.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa

final class TasksViewController: ViewController {

    // MARK: - ViewModel
    fileprivate var viewModel: TasksViewControllerViewModelType!

    // MARK: - @IBOutlet
    @IBOutlet fileprivate weak var tasksTableView: TableView!

    // MARK: - ViewController Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        configureUI()
    }

    private func configureUI() {
    }

    private func bindViewModel() {
        viewModel.bind(inputs: TasksViewControllerViewModel.Inputs())
            .disposed(by: disposeBag)

        viewModel.outputs
            .sectionsModels
            .drive(tasksTableView.rx.items(dataSource: viewModel.outputs.dataSource))
            .disposed(by: disposeBag)

        viewModel.outputs
            .title
            .drive(rx.title)
            .disposed(by: disposeBag)
    }
}

// MARK: - Buildable
extension TasksViewController {
    class func build(withViewModel viewModel: TasksViewControllerViewModelType)
        -> TasksViewController {
        let vc = TasksViewController.loadFromNib()
        vc.viewModel = viewModel
        return vc
    }
}

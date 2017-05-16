//
//  TasksViewController.swift
//
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func configureUI() {
    }

    private func bindViewModel() {
        let viewModelOutputs = viewModel
            .transform(inputs: TasksViewControllerViewModelInputs())

        viewModelOutputs.sectionsModels
            .drive(tasksTableView.rx.items(dataSource: viewModelOutputs.dataSource))
            .disposed(by: disposeBag)

        viewModelOutputs.title
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

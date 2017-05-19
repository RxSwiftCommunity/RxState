//
//  TaskViewController.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift
import RxCocoa

final class TaskViewController: ViewController {

    // MARK: - ViewModel
    fileprivate var viewModel: TaskViewControllerViewModelType!

    // MARK: - @IBOutlet
    @IBOutlet private weak var summaryTextField: TextField!
    @IBOutlet private weak var toggleTaskStatusButton: Button!

    // MARK: - Life cycle
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
        let viewModelInputs = TaskViewControllerViewModelInputs(toggleTaskStatusButtonDidTap: toggleTaskStatusButton.rx.tap, summary: summaryTextField.rx.text, backButtonDidTap: backButton?.rx.tap)
        
        let viewModelOutputs: TaskViewControllerViewModelOutputs = viewModel.transform(inputs: viewModelInputs)

        viewModelOutputs.summary
            .drive(summaryTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModelOutputs.toggleTaskStatusButtonIsSelected
            .drive(toggleTaskStatusButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModelOutputs.toggleTaskStatusButtonIsEnabled
            .drive(toggleTaskStatusButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModelOutputs.toggleTaskStatusButtonActivityIndicatorISAnimating
            .drive(toggleTaskStatusButton.rx.activityIndicatorIsAnimating)
            .disposed(by: disposeBag)
                
    }
}

// MARK: - Buildable
extension TaskViewController {
    class func build(withViewModel viewModel: TaskViewControllerViewModelType)
        -> TaskViewController {
        let vc = TaskViewController.loadFromNib()
        vc.viewModel = viewModel
        return vc
    }
}

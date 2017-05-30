//
//  TaskViewController.swift
//
//  Created by Nazih Shoura.
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
        setViewModelInputs()
        bindViewModelOutputs()
    }

    private func setViewModelInputs() {
        let viewModelInputs = TaskViewControllerViewModel.Inputs(
            toggleTaskStatusButtonDidTap: toggleTaskStatusButton.rx.tap
            , backButtonDidTap: backButton?.rx.tap
            , summary: summaryTextField.rx.text
        )
        
        viewModel.set(inputs: viewModelInputs)
            .disposed(by: disposeBag)
    }

    private func bindViewModelOutputs() {

        viewModel.outputs
            .summary
            .drive(summaryTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs
            .toggleTaskStatusButtonIsSelected
            .drive(toggleTaskStatusButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModel.outputs
            .toggleTaskStatusButtonIsEnabled
            .drive(toggleTaskStatusButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.outputs
            .toggleTaskStatusButtonActivityIndicatorIsAnimating
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

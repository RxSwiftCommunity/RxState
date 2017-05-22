//
//  TaskTableViewCell.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift

final class TaskTableViewCell: TableViewCell {

    // MARK: - @IBOutlet
    @IBOutlet private weak var summaryTextField: TextField!
    @IBOutlet private weak var toggleTaskStatusButton: Button!
    @IBOutlet private weak var openTaskStatusButton: Button!

    
    fileprivate(set) var viewModel: TaskTableViewCellViewModelType! {
        didSet {
            setViewModelInputs()
            bindViewModelOutputs()
        }
    }

    private func setViewModelInputs() {
        let viewModelInputs = TaskTableViewCellViewModel.Inputs(
            toggleTaskStatusButtonDidTap: toggleTaskStatusButton.rx.tap
            , openTaskButtonDidTap: openTaskStatusButton.rx.tap
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
            .toggleTaskStatusButtonActivityIndicatorISAnimating
            .drive(toggleTaskStatusButton.rx.activityIndicatorIsAnimating)
            .disposed(by: disposeBag)
    }
}

protocol Buildable {
    associatedtype ViewModel: ViewModelType
    static func build(withViewModel viewModel: ViewModel)
}

extension TaskTableViewCell {
    class func build(withViewModel viewModel: TaskTableViewCellViewModelType, forTableView tableView: UITableView)
        -> TaskTableViewCell {
        let cell: TaskTableViewCell = { () -> TaskTableViewCell in
            // Useing `dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier) as? TaskTableViewCell` over `dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath)` gives the advantage of knowing when the cell is created and when it's reused.
            // Quite important for debugging memory leaks and subscription disposal
            if let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier) as? TaskTableViewCell {
                return cell
            } else {
                return TaskTableViewCell.loadFromNib()
            }
        }()

        cell.viewModel = viewModel
        return cell
    }
}

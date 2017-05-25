//
//  AddTaskTableViewCell.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxCocoa
import RxSwift
import RxState

final class AddTaskTableViewCell: TableViewCell {
    
    // MARK: - @IBOutlet
    @IBOutlet private weak var addTaskButton: Button!
    
    
    var viewModel: AddTaskTableViewCellViewModelType! {
        didSet {
            setViewModelInputs()
            bindViewModelOutputs()
        }
    }
    
    private func setViewModelInputs() {
        let viewModelInputs = AddTaskTableViewCellViewModel.Inputs(addTaskButtonDidTap: addTaskButton.rx.tap)
        
        viewModel.set(inputs: viewModelInputs)
            .disposed(by: disposeBag)
    }

    private func bindViewModelOutputs() {
        viewModel.outputs.addTaskButtonActivityIndicatorIsAnimating
            .drive(addTaskButton.rx.activityIndicatorIsAnimating)
            .disposed(by: disposeBag)
    }
}

extension AddTaskTableViewCell {
    class func build(withViewModel viewModel: AddTaskTableViewCellViewModelType, forTableView tableView: UITableView)
        -> AddTaskTableViewCell {
            let cell: AddTaskTableViewCell = { () -> AddTaskTableViewCell in
                if let cell = tableView.dequeueReusableCell(withIdentifier: AddTaskTableViewCell.reuseIdentifier) as? AddTaskTableViewCell {
                    return cell
                } else {
                    return AddTaskTableViewCell.loadFromNib()
                }
            }()
            
            cell.viewModel = viewModel
            return cell
    }
}

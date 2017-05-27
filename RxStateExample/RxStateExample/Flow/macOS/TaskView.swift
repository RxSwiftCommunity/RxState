//
//  TaskView.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Cocoa

class TaskView: View {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    var viewModel: TaskViewViewModelType! {
        didSet {
            setViewModelInputs()
            bindViewModelOutputs()
        }
    }
    
    @IBOutlet weak var SummaryTextField: NSTextField!
    @IBOutlet private weak var toggleTaskStatusButton: NSButton!

    private func setViewModelInputs(){
        let viewModelInputs = TaskViewViewModel.Inputs(
            toggleTaskStatusButtonDidTap: toggleTaskStatusButton.rx.tap
            , summary: SummaryTextField.rx.text
        )
        
        viewModel.set(inputs: viewModelInputs)
            .disposed(by: disposeBag)
    }

    private func bindViewModelOutputs(){
        viewModel.outputs
            .summary
            .drive(SummaryTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs
            .toggleTaskStatusButtonIsSelected
            .drive(toggleTaskStatusButton.rx.state)
            .disposed(by: disposeBag)
    }
}

// MARK: - Buildable
extension TaskView {
    class func build(withViewModel viewModel: TaskViewViewModelType)
        -> TaskView {
            let view = TaskView.loadFromNib()
            view.viewModel = viewModel
            return view
    }
}

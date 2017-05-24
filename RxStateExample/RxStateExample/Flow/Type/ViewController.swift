//
//  ViewController.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import RxSwift
import UIKit

protocol ViewControllerType: HasDisposeBag, Identifiable, SubjectLabelable {}

class ViewController: UIViewController, ViewControllerType {

    var disposeBag = DisposeBag()
    let id = Foundation.UUID().uuidString

    weak var backButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func addBackButton() {
        navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
        self.backButton = backButton
    }
}

//
//  ViewController.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import RxSwift
import Cocoa

protocol ViewControllerType: HasDisposeBag, Identifiable, SubjectLabelable {}

class ViewController: NSViewController, ViewControllerType {
    
    var disposeBag = DisposeBag()
    let id = Foundation.UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }    
}

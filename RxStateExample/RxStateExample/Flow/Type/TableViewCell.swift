//
//  TableViewCell.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import UIKit
import RxSwift

protocol TableViewCellType: HasDisposeBag, ResusableView {}

class TableViewCell: UITableViewCell, TableViewCellType {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeOnReuse()
    }
}

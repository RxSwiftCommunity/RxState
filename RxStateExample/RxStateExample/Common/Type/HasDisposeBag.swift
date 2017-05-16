//
//  HasDisposeBag.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import RxSwift

protocol HasDisposeBag {
    var disposeBag: DisposeBag { get set }
}

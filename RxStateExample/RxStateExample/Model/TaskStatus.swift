//
//  TaskStatus.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift

enum TaskStatus: ModelType, Equatable {
    case todo
    case done

    var id: String {
        return "\(self)"
    }
}

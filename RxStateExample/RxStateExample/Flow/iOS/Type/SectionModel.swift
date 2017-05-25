//
//  SectionModel.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxDataSources

struct SectionModel: SectionModelType, SubjectLabelable, CustomDebugStringConvertible {
    var items: [SectionItemModelType]
    init(items: [SectionItemModelType]) {
        self.items = items
    }
    
    typealias Item = SectionItemModelType
    init(original: SectionModel, items: [SectionItemModelType]) {
        self = original
        self.items = items
    }
    
    var debugDescription: String {
        let result = "\(self.subjectLabel)\nitems: \(items)\n"
        return result
    }
}

protocol SectionItemModelType {}

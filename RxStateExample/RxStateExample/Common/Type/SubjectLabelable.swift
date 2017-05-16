//
//  SubjectLabelable.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation

protocol SubjectLabelable {
    static var subjectLabel: String { get }
    var subjectLabel: String { get }
}

extension SubjectLabelable {
    static var subjectLabel: String {
        let result = String(describing: self)
        return result
    }

    var subjectLabel: String {
        let result = String(describing: type(of: self))
        return result
    }
}

extension NSObject: SubjectLabelable {}

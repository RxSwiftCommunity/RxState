//
//  ReuseIdentifiable.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import class UIKit.UITableViewCell
import class UIKit.UITableViewHeaderFooterView

protocol ReuseIdentifiable: SubjectLabelable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    public static var reuseIdentifier: String {
        return Self.subjectLabel
    }
}

extension UITableViewCell: ReuseIdentifiable {}

extension UITableViewHeaderFooterView: ReuseIdentifiable {}

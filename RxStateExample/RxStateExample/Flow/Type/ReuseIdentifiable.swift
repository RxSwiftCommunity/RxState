//
//  ReuseIdentifiable.swift
//
//  Created by Nazih Shoura.
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation

protocol ReuseIdentifiable: SubjectLabelable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    public static var reuseIdentifier: String {
        return Self.subjectLabel
    }
}

#if os(iOS)
import class UIKit.UITableViewCell
import class UIKit.UITableViewHeaderFooterView


extension UITableViewCell: ReuseIdentifiable {}
extension UITableViewHeaderFooterView: ReuseIdentifiable {}
    
#endif

//
//  Task.swift
//
//  Copyright © 2017 Nazih Shoura. All rights reserved.
//  See LICENSE.txt for license information
//

import Foundation
import RxSwift

typealias TaskId = String

struct Task: ModelType, CustomDebugStringConvertible, Equatable {

    let id: TaskId
    var summary: String
    var status: TaskStatus

    var hashValue: Int {
        return id.hashValue
    }

    init(
        id: TaskId = _taskIdGeneratore
        , summary: String
        , status: TaskStatus
    ) {
        self.id = id
        self.summary = summary
        self.status = status
    }

    /// A textual representation of this instance, suitable for debugging.
    var debugDescription: String {
        let result = "Task\n"
            + "id = \(id)\n"
            + "summary = \(summary)\n"
            + "status = \(status)\n"

        return result
    }

    static func ==(lhs: Task, rhs: Task) -> Bool {
        return lhs.id == rhs.id
            && lhs.summary == rhs.summary
            && lhs.status == rhs.status
    }
}

// Of course this is for simplification :)
extension Task {
    fileprivate static var _taskIdGeneratore: TaskId {
        return Foundation.UUID().uuidString
    }
}

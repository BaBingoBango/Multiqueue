//
//  OperationStatus.swift
//  Multiqueue
//
//  Created by Ethan Marshall on 7/30/22.
//

import Foundation

/// The status of an operation that takes time and can fail, such as a network request.
enum OperationStatus {
    /// The case in which the operation has not yet been attempted.
    case notStarted
    
    /// The case in which the operation is currently underway.
    case inProgress
    
    /// The case in which the operation has completed successfully.
    case success
    
    /// The case in which the operation is complete but has failed.
    case failure
}

//
//  SessionDelegate.swift
//  NetworkManager
//
//  Created by Michał Rogowski on 24/02/2018.
//  Copyright © 2018 Michal Rogowski. All rights reserved.
//

import Foundation

class SessionDelegate: NSObject {
    private var requests: [Int: DataRequest] = [:]
    private let lock = NSLock()
    
    /// Access the task delegate for the specified task in a thread-safe manner.
    open subscript(task: URLSessionTask) -> DataRequest? {
        get {
            lock.lock() ; defer { lock.unlock() }
            return requests[task.taskIdentifier]
        }
        set {
            lock.lock() ; defer { lock.unlock() }
            requests[task.taskIdentifier] = newValue
        }
    }
}

extension SessionDelegate: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let coordinator = self[dataTask]?.taskCoordinator else { return }
        coordinator.urlSession(session, dataTask: dataTask, didReceive: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let coordinator = self[task]?.taskCoordinator else { return }
        coordinator.urlSession(session, task: task, didCompleteWithError: error)    
        self[task] = nil
    }    
}

extension SessionDelegate: URLSessionTaskDelegate {
    
}

extension SessionDelegate: URLSessionDataDelegate {

}

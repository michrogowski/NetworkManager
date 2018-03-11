//
//  DataTaskCoordinator.swift
//  NetworkManager
//
//  Created by Michał Rogowski on 23/02/2018.
//  Copyright © 2018 Michal Rogowski. All rights reserved.
//

import Foundation

public final class DataTaskCoordinator: NSObject, TaskCoordinator {
    
    public var error: Error?
    
    /// The serial operation queue used to execute all operations after the task completes.
    public var queue: OperationQueue
    
    public var urlTask: URLSessionTask? {
        set {
            taskLock.lock();
            defer { taskLock.unlock() }
            _task = newValue
        }
        get {
            taskLock.lock(); defer { taskLock.unlock() }
            return _task
        }
    }
    
    private let taskLock = NSLock()
    
    private var _task: URLSessionTask? {
        didSet{
            reset()
        }
    }
    
    public var progress: Progress = Progress(totalUnitCount: 0)
    
    var responseData = Data()
    
    var initialResponseTime: CFAbsoluteTime?

    private var totalBytesReceived: Int64 = 0
    
    public override init() {
        self.queue = {
            let operationQueue = OperationQueue()
            
            operationQueue.maxConcurrentOperationCount = 1
            operationQueue.isSuspended = true
            operationQueue.qualityOfService = .utility
            
            return operationQueue
        }()
    }
    
    public func reset() {
        progress = Progress(totalUnitCount: 0)
        responseData = Data()
        totalBytesReceived = 0                
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if initialResponseTime == nil {
            initialResponseTime = CFAbsoluteTimeGetCurrent()
        }
        
        responseData.append(data)
        
        let bytesReceived = Int64(data.count)
        totalBytesReceived += bytesReceived
        let totalBytesExpected = dataTask.response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
        
        progress.totalUnitCount = totalBytesExpected
        progress.completedUnitCount = totalBytesReceived
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            if self.error == nil {
                self.error = error
            }
        }
        
        queue.isSuspended = false
    }

}

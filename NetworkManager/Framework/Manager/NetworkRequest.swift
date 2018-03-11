//
//  NetworkTask.swift
//  NetworkManager
//
//  Created by Michał Rogowski on 21/02/2018.
//  Copyright © 2018 Michal Rogowski. All rights reserved.
//

import Foundation


public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

/// NetworkTask to create request
public protocol NetworkRequest: class {
    
    var startTime: CFAbsoluteTime? { set get }
    
    var endTime: CFAbsoluteTime? { set get }
    
    /// HTTP URL.
    var endpoint: String { set get }
    
    /// Query method.
    var method: HTTPMethod { get }
    
    /// Query parameters,
    var parametersData: Data? { get }
        
    /// Cache policy for this task
    var cachePolicy: NSURLRequest.CachePolicy { get }
    
    /// Set number of retries, default is 0
    var numberOfRetries: Int { set get }
    
    var taskCoordinator: TaskCoordinator { set get }
    
    var headers: [String: String]? { get }
    
    func task(for session: URLSession, queue: DispatchQueue) -> URLSessionTask?
    
    func resume()
    
    func suspend()
    
    func cancel()
    
    func shouldRetry(for dataResponse: DataResponse) -> Bool
}

public extension NetworkRequest {
    
    var startTime: CFAbsoluteTime? { return nil }
    
    var endTime: CFAbsoluteTime? { return nil }
    
    var parametersData: Data? { return nil }
    
    var method: HTTPMethod { return .get }
    
    var cachePolicy: NSURLRequest.CachePolicy { return .useProtocolCachePolicy }
        
    var numberOfRetries: Int { return 0 }
    
    var headers: [String: String]? { return nil }
    
    func resume() {
        guard let task = taskCoordinator.urlTask else {
            taskCoordinator.queue.isSuspended = false
            return
        }

        if startTime == nil {
            startTime = CFAbsoluteTimeGetCurrent()
        }
        
        task.resume()
    }
    
    func suspend() {
        taskCoordinator.urlTask?.suspend()
    }
    
    func cancel() {
        taskCoordinator.urlTask?.cancel()
    }
        
}

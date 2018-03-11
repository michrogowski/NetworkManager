//
//  DataRequest.swift
//  NetworkManager
//
//  Created by Michał Rogowski on 23/02/2018.
//  Copyright © 2018 Michal Rogowski. All rights reserved.
//

import Foundation

open class DataRequest: NetworkRequest {
    
    open var endpoint: String = ""
    
    open var method: HTTPMethod = .get
    
    public var endTime: CFAbsoluteTime?
    
    public var startTime: CFAbsoluteTime?
    
    open var numberOfRetries: Int = 0
    
    public var taskCoordinator: TaskCoordinator
    
    open var parametersData: Data? { return nil }
    
    /// The request sent or to be sent to the server.
    open var request: URLRequest? {
        return taskCoordinator.urlTask?.originalRequest
    }
    
    /// The response received from the server, if any.
    open var response: HTTPURLResponse? {
        return taskCoordinator.urlTask?.response as? HTTPURLResponse
    }
    
    public func shouldRetry(for dataResponse: DataResponse) -> Bool {
        return false
    }
    
    private var dataCoordinator: DataTaskCoordinator? {
        return taskCoordinator as? DataTaskCoordinator
    }
    
    public init() {
        taskCoordinator = DataTaskCoordinator()
        
        taskCoordinator.queue.addOperation {
            self.endTime = CFAbsoluteTimeGetCurrent()
        }
    }
    
    public func task(for session: URLSession, queue: DispatchQueue) -> URLSessionTask? {
        
        let timeout = session.configuration.timeoutIntervalForRequest
        guard let task = NetworkTask(request: self, timeout: timeout) else { return nil }
        
        return queue.sync { session.dataTask(with: task as URLRequest) }
    }
        
    @discardableResult
    public func response(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse) -> Void) -> Self {
        dataCoordinator?.queue.addOperation {
            (queue ?? DispatchQueue.main).async {
                let data = self.dataCoordinator?.responseData
                let error = self.dataCoordinator?.error
                
                let duration: TimeInterval?
                
                if let endTime = self.endTime, let startTime = self.startTime {
                    duration = endTime - startTime
                } else {
                    duration = nil
                }
                
                let dataResponse = DataResponse(request: self.request, response: self.response, data: data, error: error, duration: duration)
                completionHandler(dataResponse)
            }
        }
        
        return self
    }
}

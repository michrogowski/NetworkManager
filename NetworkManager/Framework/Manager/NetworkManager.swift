//
//  MainClass.swift
//  NetworkManager
//
//  Created by Michał Rogowski on 21/02/2018.
//  Copyright © 2018 Michal Rogowski. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public final class NetworkManager {
    
    private let delegate = SessionDelegate()
    private let timeout: TimeInterval
    private let memoryCapacity: Int
    private let diskCapacity: Int
    
    let queue = DispatchQueue(label: "org.networkManager.session-manager." + UUID().uuidString)

    /// Initialize Network Manager
    ///
    /// - Parameters:
    ///   - timeout: Timeout interval for requests and resources
    ///   - memoryCapacity: Cache memory capacity in megabytes
    ///   - diskCapacity: Cache disk capacity in megabytes
    public init(timeout: TimeInterval = 60, memoryCapacity: Int = 20, diskCapacity: Int = 100) {

        let megabytesToBytes = 1000000
        
        self.timeout = timeout
        self.memoryCapacity = memoryCapacity * megabytesToBytes
        self.diskCapacity = diskCapacity * megabytesToBytes
    }
    
    private lazy var session: URLSession = {
        return URLSession(configuration: self.sessionConfiguration(), delegate: delegate, delegateQueue: nil)
    }()
    
    @inline(__always) private func sessionConfiguration() -> URLSessionConfiguration {
        
        let config = URLSessionConfiguration.default
        
        config.httpAdditionalHeaders = ["Authorization" : "MIveLvUSlMQVIOixysALYPdOGyVzyaXgyKQVnbjL"]
        
        config.timeoutIntervalForRequest = timeout
        
        config.timeoutIntervalForResource = timeout
        
        config.httpMaximumConnectionsPerHost = 5
        
        config.urlCache = URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: nil)
        
        config.requestCachePolicy = .useProtocolCachePolicy
        
        return config
    }
    
    public func response(dataRequest: DataRequest) {
        guard let task = dataRequest.task(for: session, queue: queue) else { return }
        
        delegate[task] = dataRequest
        dataRequest.taskCoordinator.urlTask = task
        
        dataRequest.resume()
    }

    public func response(for dataRequest: DataRequest) -> Observable<DataResponse> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.response(dataRequest: dataRequest)

            dataRequest.response(completionHandler: { [weak self] dataResponse in
                self?.handle(dataResponse: dataResponse, for: dataRequest, observer: observer)
            })
            
            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }
    
    private func handle(dataResponse: DataResponse, for dataRequest: DataRequest, observer: AnyObserver<DataResponse>) {
        guard dataRequest.numberOfRetries == 0,
            !dataRequest.shouldRetry(for: dataResponse) else {
                
            dataRequest.numberOfRetries -= 1
            response(dataRequest: dataRequest)
            
            dataRequest.response(completionHandler: { [weak self] dataResponse in
                self?.handle(dataResponse: dataResponse, for: dataRequest, observer: observer)
            })
            
            return
        }
        
        if let error = dataResponse.error {
            observer.onError(error)
            return
        }
        
        observer.onNext(dataResponse)
        
        observer.onCompleted()
    }
    
    public func request(for dataRequest: DataRequest) -> Observable<DataRequest> {
        return Observable.create { [weak self] observer -> Disposable in
            self?.response(dataRequest: dataRequest)
            
            dataRequest.response(completionHandler: { [weak self] dataResponse in
                self?.handle(dataRequest: dataRequest, for: dataResponse, observer: observer)
            })
            
            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }
    
    private func handle(dataRequest: DataRequest, for dataResponse: DataResponse, observer: AnyObserver<DataRequest>) {
        guard dataRequest.numberOfRetries == 0,
            !dataRequest.shouldRetry(for: dataResponse) else {
                
                dataRequest.numberOfRetries -= 1
                response(dataRequest: dataRequest)
                
                dataRequest.response(completionHandler: { [weak self] dataResponse in
                    self?.handle(dataRequest: dataRequest, for: dataResponse, observer: observer)
                })
                
                return
        }
        
        if let error = dataResponse.error {
            observer.onError(error)
            return
        }
        
        observer.onNext(dataRequest)
        
        observer.onCompleted()

    }
}

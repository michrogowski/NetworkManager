//
//  TaskCoordinator.swift
//  NetworkManager
//
//  Created by Michał Rogowski on 22/02/2018.
//  Copyright © 2018 Michal Rogowski. All rights reserved.
//

import Foundation

public protocol TaskCoordinator: class {
    
    var urlTask: URLSessionTask? { set get }
    
    var progress: Progress { set get }
    
    var queue: OperationQueue { set get }
    
    var error: Error? { set get }
    
    func reset()
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}

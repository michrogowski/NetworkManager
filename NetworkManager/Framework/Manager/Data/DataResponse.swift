//
//  DataResponse.swift
//  NetworkManager
//
//  Created by Michał Rogowski on 24/02/2018.
//  Copyright © 2018 Michal Rogowski. All rights reserved.
//

import Foundation

public struct DataResponse {
    public var request: URLRequest?
    public var response: HTTPURLResponse?
    public var data: Data?
    public var error: Error?
    public var duration: TimeInterval?
    
    @discardableResult
    public func map<T>(to type: T.Type) throws -> T where T : Codable {
        guard let responseData = data else { throw NSError(domain: "yoo", code: 1, userInfo: [:]) }
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(T.self, from: responseData)
        } catch let error as NSError {
            throw error
        }
    }
    
    var isStatusSuccess: Bool {
        guard let code = response?.statusCode else { return false }
        return 200 ..< 300 ~= code
    }

}

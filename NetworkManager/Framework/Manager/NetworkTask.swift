//
//  NetworkRequest.swift
//  NetworkManager
//
//  Created by Michał Rogowski on 21/02/2018.
//  Copyright © 2018 Michal Rogowski. All rights reserved.
//

import Foundation

private extension NetworkRequest {
    var isURI: Bool {
        return method == .get || method == .head
    }
}

public final class NetworkTask: NSMutableURLRequest {
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("aDecoder is not initialized for NetworkTask")
    }
    
    public init?(request: NetworkRequest, timeout: TimeInterval) {
        
        let convertedURL = [request.endpoint].flatMap { URL(string: String($0)) }.first
        
        guard let url = convertedURL else {
            assertionFailure("cannot create url for \(request.endpoint)")
            return nil
        }
        
        super.init(url: url, cachePolicy: request.cachePolicy, timeoutInterval: timeout)
        
        addValue("application/json", forHTTPHeaderField: "Content-Type")
//        addValue("gzip", forHTTPHeaderField: "Content-Encoding")
        
        httpMethod = request.method.rawValue
        
        if !request.isURI {
            httpBody = request.parametersData
        } else if let data = request.parametersData {
            setupURIParameters(for: data)
        }
    }
    
    private func setupURIParameters(for data: Data) {
        guard let dataString = String(data: data, encoding: .utf8), let url = url else { return }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        guard let dictionary = convertToDictionary(text: dataString) else { return }
        
        urlComponents?.queryItems = dictionary.flatMap {
            return URLQueryItem(name: $0.key, value: $0.value as? String ?? String(describing: $0.value))
        }
        
        self.url = urlComponents?.url
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            } catch {
                assertionFailure(error.localizedDescription)
            }
        }
        return nil
    }
}

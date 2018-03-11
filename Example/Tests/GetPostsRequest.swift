//
//  GetPostsRequest.swift
//  NetworkManager_Example
//
//  Created by Michał Rogowski on 10/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import NetworkManager
@testable import RxSwift
@testable import RxCocoa

class GetPostsRequest: DataRequest {
    
    override init() {
        super.init()
        
        endpoint = "http://localhost:3000/posts"
    }
}


class GetPostsRequestRetry: DataRequest {
        
    override init() {
        super.init()
        numberOfRetries = 3
        endpoint = "http://localhost:3000/posts2"
    }
    
    override func shouldRetry(for dataResponse: DataResponse) -> Bool {
        return dataResponse.isStatusSuccess
    }
    
}

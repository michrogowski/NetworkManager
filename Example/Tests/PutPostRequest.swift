//
//  PutPostRequest.swift
//  NetworkManager_Tests
//
//  Created by Michał Rogowski on 10/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import NetworkManager
@testable import RxSwift
@testable import RxCocoa

class PutPostRequest: DataRequest {
    
    let post: Post
    
    override var parametersData: Data? {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(post)
        return data
    }
    
    init(post: Post) {
        self.post = post
        super.init()
        
        method = .put
        endpoint = "http://localhost:3000/posts/" + String((post.id ?? 0))
    }
}

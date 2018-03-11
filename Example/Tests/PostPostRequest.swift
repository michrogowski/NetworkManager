//
//  PostPostRequest.swift
//  NetworkManager_Tests
//
//  Created by Michał Rogowski on 10/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import NetworkManager
@testable import RxSwift
@testable import RxCocoa

class PostPostRequest: DataRequest {
    
    let post = Post(id: nil, title: "Testowy tytul", author: "Yoo test dziala")
    
    override var parametersData: Data? {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(post)
        return data
    }
    
    override init() {
        super.init()
        method = .post
        endpoint = "http://localhost:3000/posts"
    }
}

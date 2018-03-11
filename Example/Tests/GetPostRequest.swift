//
//  GetPostRequest.swift
//  NetworkManager_Tests
//
//  Created by Michał Rogowski on 10/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import RxCocoa
@testable import RxSwift
@testable import NetworkManager

class GetPostRequest: DataRequest {
    
    let postId: Int
    init(postId id: Int) {
        postId = id
        super.init()
        
        endpoint = "http://localhost:3000/posts/\(postId)"
    }
}

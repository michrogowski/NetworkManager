//
//  DeletePostRequest.swift
//  NetworkManager_Tests
//
//  Created by Michał Rogowski on 10/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
@testable import NetworkManager
@testable import RxSwift
@testable import RxCocoa

class DeletePostRequest: DataRequest {
    
    
    let idToDelete: Int
    
    init(postId: Int) {
        idToDelete = postId
        
        super.init()
        method = .delete
        endpoint = "http://localhost:3000/posts/" + String(postId)
    }
}

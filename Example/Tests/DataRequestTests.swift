import XCTest
@testable import NetworkManager
@testable import RxSwift
@testable import RxCocoa

struct Post: Codable {
    let id: Int?
    let title: String?
    let author: String?
}

struct Comment: Codable {
    let id: Int
    let body: String
    let postId: Int
}

class DataRequestTests: XCTestCase {
    
    let networkManager = NetworkManager()
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        //TODO: FIX AFTER SERVER WILL BE FASTER
        sleep(1)
        continueAfterFailure = true
    }
    
    func testGetPosts() {
        let getExpectation = expectation(description: "Creating basic get request")
        
        networkManager
            .response(for: GetPostsRequest())
            .debug()
            .filter { $0.isStatusSuccess }
            .map { try! $0.map(to: [Post].self) }
            .subscribe(onError: { (error) in
                XCTAssertThrowsError(error)
            }) {
                getExpectation.fulfill()
            }.disposed(by: disposeBag)
        
        wait(for: [getExpectation], timeout: 5)
    }
    
    func testPostPosts() {
        let postExpectation = expectation(description: "Creating basic post request")
        let request = PostPostRequest()
        
        networkManager
            .response(for: request)
            .debug()
            .filter { $0.isStatusSuccess }
            .map { try? $0.map(to: Post.self) }
            .subscribe(onNext: { (post) in
                XCTAssertNotNil(post)
                XCTAssertEqual(post?.title, request.post.title)
                XCTAssertEqual(post?.author, request.post.author)
            }, onError: { (error) in
                XCTAssertThrowsError(error)
            }) {
                postExpectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        wait(for: [postExpectation], timeout: 5)
    }
    
    func testDeletePosts() {
        let deleteExpectation = expectation(description: "Creating basic delete request")
        
        networkManager
            .response(for: PostPostRequest())
            .debug()
            .filter { $0.isStatusSuccess }
            .map { try! $0.map(to: Post.self) }
            .flatMap { self.networkManager.response(for: DeletePostRequest(postId: $0.id!)) }
            .filter { $0.isStatusSuccess }
            .subscribe(onNext: { (dataRespone) in
                XCTAssertTrue(dataRespone.isStatusSuccess)
            }, onError: { (error) in
                XCTAssertThrowsError(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                deleteExpectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [deleteExpectation], timeout: 5)
    }
    
    func testPutPosts() {
        let putExpectation = expectation(description: "Creating basic put request")
        
        networkManager
            .response(for: PostPostRequest())
            .debug()
            .filter { $0.isStatusSuccess }
            .map { try! $0.map(to: Post.self) }
            .map { Post(id: $0.id, title: "new Title", author: "new author") }
            .flatMap { self.networkManager.response(for: PutPostRequest(post: $0)) }
            .map { try! $0.map(to: Post.self) }
            .subscribe(onNext: { post in
                XCTAssertEqual("new author", post.author)
                XCTAssertEqual("new Title", post.title)
            }, onError: { (error) in
                XCTAssertThrowsError(error)
            }) {
                putExpectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        wait(for: [putExpectation], timeout: 5)
    }
    
    func testPatchPosts() {
        let patchExpectation = expectation(description: "Creating basic patch request")
        
        networkManager
            .response(for: PostPostRequest())
            .debug()
            .filter { $0.isStatusSuccess }
            .map { try! $0.map(to: Post.self) }
            .map { Post(id: $0.id, title: nil, author: "Krzys") }
            .flatMap { self.networkManager.response(for: PatchPostRequest(post: $0)) }
            .map { try! $0.map(to: Post.self) }
            .subscribe(onNext: { post in
                XCTAssertEqual("Krzys", post.author)
                XCTAssertEqual("Testowy tytul", post.title)
            }, onError: { (error) in
                XCTAssertThrowsError(error)
            }) {
                patchExpectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        wait(for: [patchExpectation], timeout: 5)
    }
    
    func testGetPostsRertry() {
        let getExpectation = expectation(description: "Creating basic get request")
        
        networkManager
            .response(for: GetPostsRequestRetry())
            .debug()            
            .map { try? $0.map(to: [Post].self) }
            .subscribe(onNext: { post in
                XCTAssertNil(post)
            }, onError: { (error) in
                XCTAssertThrowsError(error)
            }) {
                getExpectation.fulfill()
            }.disposed(by: disposeBag)
        
        wait(for: [getExpectation], timeout: 5)
    }
}

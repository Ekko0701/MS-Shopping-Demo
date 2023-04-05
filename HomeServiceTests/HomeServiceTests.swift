//
//  HomeServiceTests.swift
//  HomeServiceTests
//
//  Created by Ekko on 2023/04/04.
//

import XCTest
import RxSwift
import Alamofire

@testable import MS_Shopping_Demo

final class HomeServiceTests: XCTestCase {

    var sut: HomeServiceProtocol!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        super.setUp()
        let session: Session = {
            let configuration: URLSessionConfiguration = {
                let configuration = URLSessionConfiguration.default
                configuration.protocolClasses = [MockURLProtocol.self]
                return configuration
            }()
            return Session(configuration: configuration)
        }()
        sut = HomeService(session: session)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        super.tearDown()
        sut = nil
        disposeBag = nil
    }
    
    func test_request_responseCode_200() {
        // given
        MockURLProtocol.responseWithDTO(type: .home)
        MockURLProtocol.responseWithStatusCode(code: 200)
        
        let expectation = XCTestExpectation(description: "Success")
        
        let observable = sut.fetchHomes()
        observable.subscribe { result in
            switch result {
            case .next(let response):
                XCTAssertEqual(response.banners[0].id!, 1)
                expectation.fulfill()
            case .error(let error):
                debugPrint(error)
                XCTFail()
            case .completed:
                print("complete")
            }
        }.disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
}

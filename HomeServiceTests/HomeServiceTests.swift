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
        //MockURLProtocol.responseWithDTO(type: .home)
        MockURLProtocol.responseWithDTO(type: .home)
        MockURLProtocol.responseWithStatusCode(code: 200)
        
        //let request = HomeService.fetchHomes()
        let expectation = XCTestExpectation(description: "Perform a request")
        
        // when
//        let observable = sut.fetchHomes()
//            .subscribe { event in
//                switch event {
//                case .success(let response):
//                    // then
//                    XCTAssertEqual(response.id, 1)
//
//                    expectation.fullfill()
//                case .failure(let error):
//                    debugPrint(error)
//                    XCTFail()
//                }
//            }.disposed(by: disposeBag)
        
        let observable = sut.fetchHomes()
        observable.subscribe { result in
            switch result {
            case .next(let response):
                XCTAssertEqual(response.banners.count, 3)
                expectation.fulfill()
            case .error(let error):
                print("에러입니다.\(error.localizedDescription)")
                XCTFail()
            default:
                XCTFail()
            }
        }.disposed(by: disposeBag)
//        //when
//        let observable = sut.fetchHomes()
//        _ = observable.subscribe(onNext: { homeData in
//            print(homeData)
//            // then
//            XCTAssertEqual(homeData.banners.count, 3)
//            expectation.fulfill()
//        }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 10)
    }
}

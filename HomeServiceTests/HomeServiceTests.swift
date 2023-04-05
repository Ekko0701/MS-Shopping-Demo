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
    
    // JSON Parsing Test도 포함.
    // With Mock
    func test_fetchHome_Observable에_next이벤트_잘전달되는지테스트() {
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
    
    func test_fetchHomes_정상작동여부테스트() {
        let expectation = XCTestExpectation(description: "fetchHome 비동기 테스트")
        
        let observable = sut.fetchHomes()
        
        _ = observable.subscribe(onNext: { homeModel in
            XCTAssertNotNil(homeModel)
            XCTAssertEqual(homeModel.banners.count, 3)
            XCTAssertEqual(homeModel.goods[0].id, 1)
            expectation.fulfill()
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    func test_fetchGoods_정상작동여부테스트() {
        let expectation = XCTestExpectation(description: "fetchGoods 비동기 테스트")
        
        let observable = sut.fetchGoods(lastId: 10)
        
        _ = observable.subscribe(onNext: { goodModel in
            XCTAssertNotNil(goodModel)
            XCTAssertEqual(goodModel.goods.count, 10)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 5)
    }
}

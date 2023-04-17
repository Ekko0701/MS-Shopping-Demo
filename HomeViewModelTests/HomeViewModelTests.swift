//
//  HomeViewModelTests.swift
//  HomeViewModelTests
//
//  Created by Ekko on 2023/04/05.
//

import XCTest

import RxSwift
import RealmSwift
@testable import MS_Shopping_Demo

/// 테스트 데이터 설정
class TestHomeService: HomeServiceProtocol {
    func fetchHomes() -> Observable<HomeModel> {
        let banners: [BannerModel] = [
            BannerModel(id: 100, image: "ImageURL_1"),
            BannerModel(id: 200, image: "ImageURL_2"),
            BannerModel(id: 300, image: "ImageURL_3"),
        ]
        
        let goods: [GoodsModel] = [
            GoodsModel(id: 100, name: "A", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
            GoodsModel(id: 200, name: "B", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
            GoodsModel(id: 300, name: "C", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
            GoodsModel(id: 400, name: "D", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
            GoodsModel(id: 500, name: "E", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
        ]
        
        let homes = HomeModel(banners: banners, goods: goods)
        
        return Observable.just(homes)
    }
    
    func fetchGoods(lastId: Int) -> Observable<GoodModel> {
        let goods: [GoodsModel] = [
            GoodsModel(id: 100, name: "A", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
            GoodsModel(id: 200, name: "B", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
            GoodsModel(id: 300, name: "C", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
            GoodsModel(id: 400, name: "D", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
            GoodsModel(id: 500, name: "E", image: "ImageURL_1", actual_price: 100, price: 110, is_new: true, sell_count: 1),
        ]
        
        let good = GoodModel(goods: goods)
        
        return Observable.just(good)
    }
}

final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        super.setUp()
        sut = HomeViewModel(domain: TestHomeService())
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
        sut = nil
        disposeBag = nil
    }
    
    /// HomeViewModel의 pushBanner 테스트
    /// BannerModel이 ViewModel로 잘 파싱되는지 동시에 테스트
    /// -> 이번엔 동시에 했지만 파싱은 따로 테스트 해야한다고 생각한다.
    func test_pushBanners() {
        let expectation = XCTestExpectation(description: "pushBanners 비동기 테스트")
        
        sut.fetchHome.onNext(())
        
        let viewBanner = [
            ViewBanner(id: 100, image: "ImageURL_1"),
            ViewBanner(id: 200, image: "ImageURL_2"),
            ViewBanner(id: 300, image: "ImageURL_3"),
        ]
        
        sut.pushBanners.subscribe(onNext: { result in
            XCTAssertEqual(viewBanner[0].id, result[0].id)
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    /// HomeViewModel의 pushGoods 테스트
    /// 위의 경우와 마찬가지
    func test_pushGoods() {
        let expectation = XCTestExpectation(description: "pushGoods 비동기 테스트")
        
        sut.fetchHome.onNext(())
        
        let viewGood = [
            ViewGoods(id: 100, name: "A", image: "ImageURL_1", actual_price: 100, discount_percentage: 110, is_new: true, sell_count: 1, isZzim: false),
            ViewGoods(id: 200, name: "B", image: "ImageURL_2", actual_price: 100, discount_percentage: 110, is_new: true, sell_count: 1, isZzim: false),
            ViewGoods(id: 300, name: "C", image: "ImageURL_3", actual_price: 100, discount_percentage: 110, is_new: true, sell_count: 1, isZzim: true),
            ViewGoods(id: 400, name: "D", image: "ImageURL_4", actual_price: 100, discount_percentage: 110, is_new: true, sell_count: 1, isZzim: false),
            ViewGoods(id: 500, name: "E", image: "ImageURL_5", actual_price: 100, discount_percentage: 110, is_new: true, sell_count: 1, isZzim: false),
        ]
        
        _ = sut.pushGoods.subscribe (onNext: { result in
            XCTAssertNotNil(result)
            XCTAssertEqual(viewGood.count, result.count)
            XCTAssertEqual(viewGood[0].image, result[0].image)
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
    
    /// zzim 버튼을 누르면 이벤트가 발생하는 touchZzimButton 테스트
    /// isZzim 상태를 확인한다.
    func test_touchZzimButton_찜한상태가아닌경우_isZzim상태업데이트테스트() {
        let expectation = XCTestExpectation(description: "touchZzim 비동기 테스트")
        
        sut.fetchHome.onNext(())
        
        sut.touchZzimButton.onNext(ViewGoods(id: 100, name: "Test", image: "TestImageUrl", actual_price: 100, discount_percentage: 30, is_new: false, sell_count: 100, isZzim: false))
        
        sut.pushGoods.subscribe(onNext: { goods in
            if let filteredGoods = goods.first(where: { $0.id == 100 }) {
                XCTAssertEqual(filteredGoods.isZzim, true)
                expectation.fulfill()
            } else {
                XCTFail()
            }
        }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
        
    }
    
    func test_touchZzimButton_찜한상태인경우_isZzim상태업데이트테스트() {
        let expectation = XCTestExpectation(description: "touchZzim 비동기 테스트")
        
        sut.fetchHome.onNext(())
        
        sut.touchZzimButton.onNext(ViewGoods(id: 200, name: "Test", image: "TestImageUrl", actual_price: 100, discount_percentage: 30, is_new: true, sell_count: 100, isZzim: true))
        
        sut.pushGoods.subscribe(onNext: { goods in
            print("굿즈 \(goods)")
            if let filteredGoods = goods.first(where: { $0.id == 200 }) {
                XCTAssertEqual(filteredGoods.is_new, true)
                expectation.fulfill()
            } else {
                XCTFail()
            }
        }).disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 5)
    }
}

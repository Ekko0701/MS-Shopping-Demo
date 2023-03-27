//
//  HomeViewModel.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import RxSwift
import RxRelay

protocol HomeViewModelType {
    // INPUT
    var fetchHome: AnyObserver<Void> { get }
    var fetchNewGoods: AnyObserver<Void> { get } // 새로운 goods를 로드할때 사용 ID를 함께 전달 받아야 함
    
    
    // OUTPUT
    var pushBanners: Observable<[BannerModel]> { get }
    var pushGoods: Observable<[GoodsModel]> { get }
    var pushNewGoods: Observable<[GoodsModel]> { get }
    var errorMessage: Observable<NSError> { get }
    
    var activated: Observable<Bool> { get }
}

class HomeViewModel: HomeViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT
    var fetchHome: RxSwift.AnyObserver<Void>
    var fetchNewGoods: RxSwift.AnyObserver<Void>
    
    // OUTPUT
    var pushBanners: RxSwift.Observable<[BannerModel]>
    var pushGoods: RxSwift.Observable<[GoodsModel]>
    var pushNewGoods: RxSwift.Observable<[GoodsModel]>
    var errorMessage: RxSwift.Observable<NSError>
    
    var activated: RxSwift.Observable<Bool>
    
    init(domain: HomeServiceProtocol = HomeService()) {
        let fetching = PublishSubject<Void>()
        let newFetching = PublishSubject<Void>()
        
        let homeDatas = BehaviorSubject<HomeModel>(value: HomeModel(banners: [], goods: []))
        let newGoodsDatas = BehaviorSubject<GoodModel>(value: GoodModel(goods: []))
        
        let goods = BehaviorSubject<[GoodsModel]>(value: [])
        
        let activating = BehaviorSubject<Bool>(value: false)
        
        let error = PublishSubject<Error>()
        
        
        // API 호출
        fetchHome = fetching.asObserver()
        fetchNewGoods = newFetching.asObserver()
        
        fetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap(domain.fetchHomes)
            .do(onNext: { _ in activating.onNext(false)})
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: homeDatas.onNext)
                .disposed(by: disposeBag)
        
        // homeDatas의 상품 목록만 goods가 구독
        homeDatas.flatMap { Observable<[GoodsModel]>.just($0.goods) }
            .subscribe(onNext: goods.onNext)
            .disposed(by: disposeBag)
                
//        newFetching
//            .flatMap { lastId in
////                domain.fetchGoods(lastId: currentGoods.last?.id)
//                domain.fetchGoods(lastId: lastId)
//            }
//            .do(onError: { err in error.onNext(err) })
//                .subscribe(onNext: newGoodsDatas.onNext)
//                .disposed(by: disposeBag)
        newFetching
        
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap { _ -> Observable<GoodModel> in
                let currentGoods = try! goods.value()
                let lastId = currentGoods.last?.id
                return domain.fetchGoods(lastId: lastId!)
            }
        
            .do(onNext: { _ in activating.onNext(false)})
            .subscribe { goodModel in
                goodModel.map { value in
                    var currentGoods = try! goods.value()
                    currentGoods.append(contentsOf: value.goods)
                    goods.onNext(currentGoods)
                }
            }.disposed(by: disposeBag)
    
                
        
        // PUSH
        // 처음 View를 로드했을때 보여주느 데이터
        pushBanners = homeDatas.map({ result in result.banners })
        pushGoods = goods
                
        // 페이지 데이터
        pushNewGoods = newGoodsDatas.map({result in result.goods})
        
        activated = activating.distinctUntilChanged()
        errorMessage = error.map { $0 as NSError }
    }
}

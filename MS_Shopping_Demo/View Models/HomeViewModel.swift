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
    var pushBanners: Observable<[ViewBanner]> { get }
    var pushGoods: Observable<[ViewGoods]> { get }
    var errorMessage: Observable<NSError> { get }
    
    var activated: Observable<Bool> { get }
}

class HomeViewModel: HomeViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT
    var fetchHome: RxSwift.AnyObserver<Void>
    var fetchNewGoods: RxSwift.AnyObserver<Void>
    
    // OUTPUT
    var pushBanners: RxSwift.Observable<[ViewBanner]>
    var pushGoods: RxSwift.Observable<[ViewGoods]>
    var errorMessage: RxSwift.Observable<NSError>
    
    var activated: RxSwift.Observable<Bool>
    
    init(domain: HomeServiceProtocol = HomeService()) {
        let fetching = PublishSubject<Void>()
        let newFetching = PublishSubject<Void>()
        
        let homeDatas = BehaviorSubject<HomeModel>(value: HomeModel(banners: [], goods: []))
        
        let goods = BehaviorSubject<[ViewGoods]>(value: [])
        
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
            .map({ $0.map { ViewGoods($0) } })
            .subscribe(onNext: goods.onNext)
            .disposed(by: disposeBag)
        
        newFetching
            .do(onNext: { _ in activating.onNext(true) })
            .flatMap { _ -> Observable<GoodModel> in
                let currentGoods = try! goods.value()
                let lastId = currentGoods.last?.id
                return domain.fetchGoods(lastId: lastId!)}
            .map({ goodModel in
                goodModel.goods.map { ViewGoods($0) }
            })
            .do(onNext: { _ in activating.onNext(false)})
                .subscribe(onNext: { viewGoods in
                    var currentGoods = try! goods.value()
                    currentGoods.append(contentsOf: viewGoods)
                    goods.onNext(currentGoods)
                }).disposed(by: disposeBag)
    
                
        
        // PUSH
        pushBanners = homeDatas.map({ $0.banners.map{ ViewBanner($0)} })
        
        pushGoods = goods
        
        activated = activating.distinctUntilChanged()
        errorMessage = error.map { $0 as NSError }
    }
}

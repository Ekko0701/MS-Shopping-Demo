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
    var fetchNewGoods: AnyObserver<Int> { get } // 새로운 goods를 로드할때 사용 ID를 함께 전달 받아야 함
    
    
    // OUTPUT
    var pushBanners: Observable<[BannerModel]> { get }
    var pushGoods: Observable<[GoodsModel]> { get }
    var pushNewGoods: Observable<[GoodsModel]> { get }
    var errorMessage: Observable<NSError> { get }
}

class HomeViewModel: HomeViewModelType {
    
    let disposeBag = DisposeBag()
    
    // INPUT
    var fetchHome: RxSwift.AnyObserver<Void>
    var fetchNewGoods: RxSwift.AnyObserver<Int>
    
    // OUTPUT
    var pushBanners: RxSwift.Observable<[BannerModel]>
    var pushGoods: RxSwift.Observable<[GoodsModel]>
    var pushNewGoods: RxSwift.Observable<[GoodsModel]>
    var errorMessage: RxSwift.Observable<NSError>
    
    init(domain: HomeServiceProtocol = HomeService()) {
        let fetching = PublishSubject<Void>()
        let newFetching = PublishSubject<Int>()
        
        let homeDatas = BehaviorSubject<HomeModel>(value: HomeModel(banners: [], goods: []))
        let newGoodsDatas = BehaviorSubject<NewGoodsModel>(value: NewGoodsModel(goods: []))
        
        
        let error = PublishSubject<Error>()
        
        
        // API 호출
        fetchHome = fetching.asObserver()
        fetchNewGoods = newFetching.asObserver()
        
        fetching
            .flatMap(domain.fetchHomes)
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: homeDatas.onNext)
                .disposed(by: disposeBag)
                
        newFetching
            .flatMap { lastId in domain.fetchGoods(lastId: lastId)}
            .do(onError: { err in error.onNext(err) })
                .subscribe(onNext: newGoodsDatas.onNext)
                .disposed(by: disposeBag)
        
        
            
                
        
        // PUSH
        // 처음 View를 로드했을때 보여주느 데이터
        pushBanners = homeDatas.map({ result in result.banners })
        pushGoods = homeDatas.map({ result in result.goods })
                
        // 페이지 데이터
        pushNewGoods = newGoodsDatas.map({result in result.goods})
        
                
        errorMessage = error.map { $0 as NSError }
    }
}

//
//  HomeViewModel.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import RxSwift

protocol HomeViewModelType {
    // INPUT
    var fetchHome: AnyObserver<Void> { get }
    
    // OUTPUT
    var pushBanners: Observable<[BannerModel]> { get }
    var pushGoods: Observable<[GoodsModel]> { get }
    var errorMessage: Observable<NSError> { get }
}

class HomeViewModel: HomeViewModelType {
    let disposeBag = DisposeBag()
    
    // INPUT
    var fetchHome: RxSwift.AnyObserver<Void>
    
    // OUTPUT
    var pushBanners: RxSwift.Observable<[BannerModel]>
    var pushGoods: RxSwift.Observable<[GoodsModel]>
    var errorMessage: RxSwift.Observable<NSError>
    
    init(domain: HomeServiceProtocol = HomeService()) {
        let fetching = PublishSubject<Void>()
        
        let homeDatas = BehaviorSubject<HomeModel>(value: HomeModel(banners: [], goods: []))
        
        let error = PublishSubject<Error>()
        
        
        // API 호출
        fetchHome = fetching.asObserver()
        
        fetching
            .flatMap(domain.fetchHomes)
            .do(onError: { err in error.onNext(err) })
            .subscribe(onNext: homeDatas.onNext)
                .disposed(by: disposeBag)
        
        // PUSH
        pushBanners = homeDatas.map({ result in result.banners })
                
        pushGoods = homeDatas.map({ result in result.goods })
                
        errorMessage = error.map { $0 as NSError }
    }
}

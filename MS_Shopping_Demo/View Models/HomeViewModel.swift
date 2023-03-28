//
//  HomeViewModel.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift

protocol HomeViewModelType {
    // INPUT
    var fetchHome: AnyObserver<Void> { get }
    var fetchNewGoods: AnyObserver<Void> { get }
    var touchZzimButton: AnyObserver<ViewGoods> { get } // 찜 버튼을 눌렀을 경우
    
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
    var touchZzimButton: RxSwift.AnyObserver<ViewGoods>
    
    
    // OUTPUT
    var pushBanners: RxSwift.Observable<[ViewBanner]>
    var pushGoods: RxSwift.Observable<[ViewGoods]>
    var errorMessage: RxSwift.Observable<NSError>
    
    var activated: RxSwift.Observable<Bool>
    
    // MARK: - Initializer
    init(domain: HomeServiceProtocol = HomeService()) {
        let fetching = PublishSubject<Void>()
        let newFetching = PublishSubject<Void>()
        let touchingZzimButton = PublishSubject<ViewGoods>()
        
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
    
        // 찜
        touchZzimButton = touchingZzimButton.asObserver()
                
        touchingZzimButton
                .withLatestFrom(goods) { touched, goods in
                    var updatedGoods = goods
                    if let index = updatedGoods.firstIndex(where: { $0.id == touched.id }) {
                        let newTouched = touched.updateZzim(!touched.isZzim)
                        updatedGoods[index] = newTouched
                        
                        // MARK: Realm
                        let realm = try! Realm()
                        
                        if let zzimGoods = realm.object(ofType: ZzimGoods.self, forPrimaryKey: newTouched.id) {
                            try! realm.write {
                                realm.delete(zzimGoods)
                            }
                        } else {
                            print(Realm.Configuration.defaultConfiguration.fileURL!)
                            
                            let zzimGoods = ZzimGoods(newTouched)
                            try! realm.write {
                                realm.add(zzimGoods)
                            }
                        }
                    }
                    return updatedGoods
                }
                .subscribe(onNext: goods.onNext)
                .disposed(by: disposeBag)
        
        // OUTPUT
        pushBanners = homeDatas.map({ $0.banners.map{ ViewBanner($0)} })
        
        pushGoods = goods.map({ allGoods in
            let realm = try! Realm()
            let allZzimGoods = realm.objects(ZzimGoods.self)
            
            var updatedGoods = try! goods.value()
            
            allZzimGoods.forEach { zzimGoods in
                if let index = updatedGoods.firstIndex(where: { $0.id == zzimGoods.id }) {
                    let newValue = updatedGoods[index].updateZzim(true)
                    updatedGoods[index] = newValue
                }
            }
            
            return updatedGoods
        })
        
        activated = activating.distinctUntilChanged()
        
        errorMessage = error.map { $0 as NSError }
    }
}

//
//  ZzimViewModel.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/28.
//

import Foundation
import RxSwift
import RxRelay
import RealmSwift

protocol ZzimViewModelType {
    // INPUT
    var fetchZzimGoods: AnyObserver<Void> { get }
    
    // OUTPUT
    var pushZzimGoods: Observable<[ViewGoods]> { get }
    
    var errorMessage: Observable<NSError> { get }
}

class ZzimViewModel: ZzimViewModelType {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // INPUT
    var fetchZzimGoods: RxSwift.AnyObserver<Void>
    
    // OUTPUT
    var pushZzimGoods: RxSwift.Observable<[ViewGoods]>
    var errorMessage: RxSwift.Observable<NSError>
    
    // MARK: - Initializer
    init() {
        let fetching = PublishSubject<Void>()
        
        let zzimDatas = BehaviorSubject<[ViewGoods]>(value: [])
        
        let error = PublishSubject<Error>()
        
        fetchZzimGoods = fetching.asObserver()
        
        fetching.flatMap { () -> Observable<[ViewGoods]> in
            let realm = try! Realm()
            let results = realm.objects(ZzimGoods.self)
            
            var goods: [ViewGoods] = []
            
            results.forEach { zzimGoods in
                goods.append(ViewGoods(zzimGoods))
            }
            return Observable<[ViewGoods]>.just(goods)
        }.subscribe(onNext: zzimDatas.onNext)
            .disposed(by: disposeBag)
        
        // OUTPUT
        pushZzimGoods = zzimDatas
        
        errorMessage = error.map { $0 as NSError }
            
    }
}

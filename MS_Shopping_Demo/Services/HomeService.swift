//
//  HomeService.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import Alamofire
import RxSwift


protocol HomeServiceProtocol {
    func fetchHomes() -> Observable<HomeModel>
    func fetchGoods(lastId: Int) -> Observable<GoodModel>
}

class HomeService: HomeServiceProtocol {
    
    private let session: Session
    
    init(session: Session = Session.default) {
        self.session = session
    }
    
    func fetchHomes() -> Observable<HomeModel> {
        return Observable.create { (observer) -> Disposable in
            self.fetchHomes { (error, data) in
                if let error = error {
                    observer.onError(error)
                }
                
                if let data = data {
                    observer.onNext(data)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func fetchHomes(completion:@escaping((Error?, HomeModel?) -> Void)) {
        let urlString = "http://d2bab9i9pr8lds.cloudfront.net/api/home"
        guard let url = URL(string: urlString) else { return completion(NSError(domain: "no url", code: 404, userInfo: nil), nil)}
        
        session.request(url,
                   method: HTTPMethod.get,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   headers: nil,
                   interceptor: nil,
                   requestModifier: nil)
        .responseDecodable(of: HomeModel.self) { response in
            print("응답 \(response.value)")
            if let error = response.error {
                return completion(error, nil)
            }
            
            if let data = response.value {
                return completion(nil, data)
            }
            
        }
    }
    
    // -------------
    func fetchGoods(lastId: Int) -> Observable<GoodModel> {
        return Observable.create { (observer) -> Disposable in
            self.fetchGoods(lastId: lastId) { (error, data) in
                if let error = error {
                    observer.onError(error)
                }
                
                if let data = data {
                    observer.onNext(data)
                }
                
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func fetchGoods(lastId: Int, completion: @escaping((Error?, GoodModel?) -> Void)) {
        let urlString = "https://d2bab9i9pr8lds.cloudfront.net/api/home/goods"
        guard let url = URL(string: urlString) else { return completion(NSError(domain: "no url", code: 404, userInfo: nil), nil)}
        
        let parameter: Parameters = [
            "lastId" : String(lastId)
        ]
        
        AF.request(url, method: HTTPMethod.get, parameters: parameter, encoding: URLEncoding.default, headers: nil,interceptor: nil,requestModifier: nil).responseDecodable(of: GoodModel.self) { response in
            if let error = response.error {
                print(error)
                return completion(error, nil)
            }
            
            if let data = response.value {
                return completion(nil, data)
            }
        }
    }
}

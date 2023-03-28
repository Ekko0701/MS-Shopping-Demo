//
//  ZzimGoods.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/28.
//

import Foundation
import RealmSwift

class ZzimGoods: Object {
    @Persisted(primaryKey: true) var id: Int?
    @Persisted var name: String?
    @Persisted var image: String?
    @Persisted var actual_price: Int?
    @Persisted var discount_percentage: Int?
    @Persisted var is_new: Bool?
    @Persisted var sell_count: Int?
    
    convenience init(_ model: ViewGoods) {
        self.init()
        self.id = model.id
        self.name = model.name
        self.image = model.image
        self.actual_price = model.actual_price
        self.discount_percentage = model.discount_percentage
        self.is_new = model.is_new
        self.sell_count = model.sell_count
    }
}

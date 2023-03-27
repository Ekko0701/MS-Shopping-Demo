//
//  ViewGoods.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/27.
//

import Foundation

struct ViewGoods: Hashable {
    let identifier = UUID()
    var id: Int?
    var name: String?
    var image: String?
    var actual_price: Int?
    var discount_percentage: Int?
    var is_new: Bool?
    var sell_count: Int?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    init(_ item: GoodsModel) {
        self.id = item.id
        self.name = item.name
        self.image = item.image
        self.actual_price = item.actual_price
        self.discount_percentage = ((100 - (100 * (item.price ?? 0)) / (item.actual_price ?? 0)))
        self.is_new = item.is_new
        self.sell_count = item.sell_count
    }
}

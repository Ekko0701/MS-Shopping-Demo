//
//  ViewGoods.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/27.
//

import Foundation

struct ViewGoods: Hashable {
    //let identifier = UUID()
    var id: Int?
    var name: String?
    var image: String?
    var actual_price: Int?
    var discount_percentage: Int?
    var is_new: Bool?
    var sell_count: Int?
    var isZzim: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(_ item: GoodsModel) {
        self.id = item.id
        self.name = item.name
        self.image = item.image
        self.actual_price = item.actual_price
        self.discount_percentage = ((100 - (100 * (item.price ?? 0)) / (item.actual_price ?? 1)))
        self.is_new = item.is_new
        self.sell_count = item.sell_count
        self.isZzim = false
    }
//
    init(id: Int?, name: String?, image: String?, actual_price: Int?, discount_percentage: Int?, is_new: Bool?, sell_count: Int?, isZzim: Bool) {
        self.id = id
        self.name = name
        self.image = image
        self.actual_price = actual_price
        self.discount_percentage = discount_percentage
        self.is_new = is_new
        self.sell_count = sell_count
        self.isZzim = isZzim
    }
    
    func updateZzim(_ isZzim: Bool) -> ViewGoods {
        return ViewGoods(id: id, name: name, image: image, actual_price: actual_price, discount_percentage: discount_percentage, is_new: is_new, sell_count: sell_count, isZzim: isZzim)
    }
}

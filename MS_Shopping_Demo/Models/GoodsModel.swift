//
//  GoodsModel.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/28.
//

import Foundation
struct GoodsModel: Decodable, Hashable {
    var id: Int?
    var name: String?
    var image: String?
    var actual_price: Int?
    var price: Int?
    var is_new: Bool?
    var sell_count: Int?
}

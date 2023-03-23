//
//  HomeModel.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation

// http://d2bab9i9pr8lds.cloudfront.net/api/home
// http://d2bab9i9pr8lds.cloudfront.net/api/home/goods?lastId={last_goods_id}
struct HomeModel: Decodable {
    var banners: [BannerModel]
    var goods: [GoodsModel]
}

struct BannerModel: Decodable {
    var id: Int?
    var image: String?
}

struct GoodsModel: Decodable {
    var id: Int?
    var name: String?
    var image: String?
    var actual_price: Int?
    var price: Int?
    var is_new: Bool?
    var sell_count: Int?
}


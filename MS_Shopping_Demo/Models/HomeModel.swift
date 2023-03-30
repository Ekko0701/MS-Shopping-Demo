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

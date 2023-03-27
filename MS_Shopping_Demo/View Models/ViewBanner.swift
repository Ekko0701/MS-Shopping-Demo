//
//  ViewBanner.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/27.
//

import Foundation

struct ViewBanner: Hashable {
    let identifier = UUID()
    var id: Int?
    var image: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    init(_ item: BannerModel) {
        self.id = item.id
        self.image = item.image
    }
}

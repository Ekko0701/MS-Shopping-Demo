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
}

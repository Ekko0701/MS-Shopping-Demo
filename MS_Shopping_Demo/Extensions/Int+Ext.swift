//
//  Int+Ext.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/24.
//

import Foundation

extension Int {
    func numberStringWithComma() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}

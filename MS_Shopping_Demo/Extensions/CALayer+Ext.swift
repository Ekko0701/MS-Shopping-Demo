//
//  CALayer+Ext.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import UIKit

extension CALayer {
    /**
        테두리 추가 메서드
     */
    func addBorder(
        width: CGFloat = 0.5,
        color: UIColor = UIColor.systemGray,
        radius: CGFloat?
    ) {
        self.borderWidth = width
        self.borderColor = color.cgColor
        
        if let radius = radius {
            cornerRadius = radius
        }
    }
}

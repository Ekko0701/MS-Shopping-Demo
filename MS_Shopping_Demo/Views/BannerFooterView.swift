//
//  BannerFooterView.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/30.
//

import Foundation
import UIKit
import SnapKit
import Then

final class BannerPageLabelDecorationView: UICollectionReusableView {
    static let identifier = "BannerPageLabelDecorationView"
    
    // MARK: Properties
    private var pageCountLabel = UILabel().then {
        $0.textColor = .black
        $0.text = "This is decoration view"
    }
    
    // MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStyle()
        setupConstraints()
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension BannerPageLabelDecorationView {
    private func configureStyle() {
        self.backgroundColor = .clear
        
    }
    
    private func setupConstraints() {
        self.addSubview(pageCountLabel)
        
        pageCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}



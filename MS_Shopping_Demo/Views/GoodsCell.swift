//
//  GoodsCell.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import UIKit
import SnapKit
import Then

final class GoodsCell: UICollectionViewCell {
    static let identifier = "ItemCell"
    
    private var itemImage = UIImageView().then {
        $0.backgroundColor = .systemBlue
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "house.fill")
    }
    
    private var priceStack = UIStackView().then {
        $0.backgroundColor = .clear
        $0.distribution = .fillProportionally
    }
    
    private var discountPercentageLabel = UILabel().then {
        $0.textColor = .systemRed
    }
    
    private var priceLabel = UILabel().then {
        $0.textColor = .black
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStyle()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureStyle() {
        self.contentView.addSubview(itemImage)
        self.contentView.addSubview(priceStack)
        
        self.priceStack.addArrangedSubview(discountPercentageLabel)
        self.priceStack.addArrangedSubview(priceLabel)
        
    }
    
    private func setupConstraints() {
        itemImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(itemImage.snp.height)
        }
        
        priceStack.snp.makeConstraints { make in
            make.top.equalTo(itemImage.snp.top)
            make.leading.equalTo(itemImage.snp.trailing).offset(16)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

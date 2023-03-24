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
import Kingfisher

final class GoodsCell: UICollectionViewCell {
    static let identifier = "ItemCell"
    
    private var goodsImage = UIImageView().then {
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
    
    private var titleLabel = UILabel().then {
        $0.textColor = .black
        $0.numberOfLines = 3
    }
    
    private var additionalStack = UIStackView().then {
        $0.axis = .horizontal
        $0.backgroundColor = .clear
        $0.distribution = .fillProportionally
    }
    
    private var isNewView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private var isnewLabel = UILabel().then {
        $0.textColor = .black
        $0.text = "NEW"
    }
    
    private var sellCountLabel = UILabel().then {
        $0.textColor = .systemGray
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
        self.contentView.addSubview(goodsImage)
        self.contentView.addSubview(priceStack)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(additionalStack)
        
        self.isNewView.addSubview(isnewLabel)
        
        self.priceStack.addArrangedSubview(discountPercentageLabel)
        self.priceStack.addArrangedSubview(priceLabel)
    }
    
    private func setupConstraints() {
        goodsImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(goodsImage.snp.width).multipliedBy(1)
            make.leading.equalToSuperview().offset(16)
        }
        
        priceStack.snp.makeConstraints { make in
            make.top.equalTo(goodsImage.snp.top)
            make.leading.equalTo(goodsImage.snp.trailing).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(priceStack.snp.bottom).offset(16)
            make.leading.equalTo(priceStack.snp.leading)
            make.trailing.equalToSuperview().offset(-32)
        }
        
        additionalStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(priceStack.snp.leading)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with viewModel: GoodsModel) {
        guard let url = viewModel.image else {
            goodsImage.image = UIImage(systemName: "house")
            return
        }
        goodsImage.kf.setImage(with: URL(string: url))
        
        guard let actualPrice = viewModel.actual_price,
              let price = viewModel.price else {
            discountPercentageLabel.text = nil
            priceLabel.text = nil
            return
        }
        discountPercentageLabel.text = String((100 - (100 * price) / actualPrice)) + "%"
        priceLabel.text = String(price)
        
        guard let goodsTitle = viewModel.name else {
            titleLabel.text = nil
            return
        }
        titleLabel.text = goodsTitle
        
        guard let isNew = viewModel.is_new else {
            print("nil입니다.")
            return
        }
        if isNew == true {
            isNewView.addSubview(isnewLabel)
            isnewLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            additionalStack.addArrangedSubview(isNewView)
            print("추가")
        }
        
        guard let sellCount = viewModel.sell_count else {
            return
        }
        
        if sellCount >= 10 {
            sellCountLabel.text = String(sellCount) + "구매중"
            additionalStack.addArrangedSubview(sellCountLabel)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

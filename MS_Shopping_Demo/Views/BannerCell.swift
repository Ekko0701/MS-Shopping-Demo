//
//  BannerCell.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//
import Foundation
import UIKit
import SnapKit
import Then

final class BannerCell: UICollectionViewCell {
    static let identifier = "BannerCell"
    
    private var bannerImage = UIImageView().then {
        $0.image = UIImage(named: "BannerSample")
        $0.contentMode = .scaleAspectFit
    }
    
    private var testLabel = UILabel().then {
        $0.backgroundColor = .cyan
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
        self.contentView.addSubview(bannerImage)
        self.contentView.addSubview(testLabel)
    }
    
    private func setupConstraints() {
        bannerImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        testLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with viewModel: BannerModel) {
        testLabel.text = viewModel.image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}


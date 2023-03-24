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
import Kingfisher

final class BannerCell: UICollectionViewCell {
    static let identifier = "BannerCell"
    
    private var bannerImage = UIImageView().then {
        $0.image = UIImage(named: "BannerSample")
        $0.contentMode = .scaleAspectFit
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
    }
    
    private func setupConstraints() {
        bannerImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with viewModel: BannerModel) {
        guard let url = viewModel.image else { return }
        bannerImage.kf.setImage(with: URL(string: url))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}


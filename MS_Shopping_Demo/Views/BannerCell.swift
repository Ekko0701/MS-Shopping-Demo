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
import RxSwift
import RxRelay

final class BannerCell: UICollectionViewCell {
    static let identifier = "BannerCell"
    
    var disposeBag = DisposeBag()
    let relayViewModel = PublishRelay<ViewBanner>()
    
    private var bannerImage = UIImageView().then {
        $0.image = UIImage(named: "BannerSample")
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureStyle()
        setupConstraints()
        configureRelay()
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
    
    // (1)
    func configure(with viewModel: ViewBanner) {
        guard let url = viewModel.image else { return }
        bannerImage.kf.setImage(with: URL(string: url))
    }
    
    // (2)
    func configureRelay() {
        relayViewModel.asDriver(onErrorJustReturn: ViewBanner(BannerModel()))
            .drive(onNext: { [weak self] model in
                if let url = model.image {
                    self?.bannerImage.kf.setImage(with: URL(string: url))
                } else {
                    self?.bannerImage.image = UIImage(systemName: "house") // placeholder
                }
            }).disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

extension BannerCell {
}


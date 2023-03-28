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
import RxSwift
import RxRelay

final class GoodsCell: UICollectionViewCell {
    static let identifier = "ItemCell"
    
    // MARK: Properties
    var disposeBag = DisposeBag()
    let relayViewModel = PublishRelay<ViewGoods>()
    
    private let zzim: () -> Void
    let zzimObservable: Observable<Void>
    
    private var goodsImage = UIImageView().then {
        $0.backgroundColor = .systemBlue
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "house.fill")
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private var priceStack = UIStackView().then {
        $0.backgroundColor = .clear
        $0.distribution = .fillProportionally
        $0.spacing = 4
    }
    
    private var discountPercentageLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .accentRed
    }
    
    private var priceLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 18)
        $0.textColor = .text_primary
    }
    
    private var titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .text_secondary
        $0.numberOfLines = 3
    }
    
    private var additionalStack = UIStackView().then {
        $0.axis = .horizontal
        $0.backgroundColor = .clear
        $0.distribution = .fillProportionally
        $0.spacing = 5
    }
    
    private var isNewView = UIView().then {
        $0.layer.addBorder(width: 0.2, color: .text_primary, radius: 2)
        $0.backgroundColor = .clear
    }
    
    private var isnewLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 10)
        $0.textColor = .text_primary
        $0.text = "NEW"
    }
    
    private var sellCountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.textColor = .text_secondary
    }
    
    private var separatorView = UIView().then {
        $0.backgroundColor = .systemGray3
    }
    
    private var zzimButton = UIButton().then {
        $0.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.tintColor = UIColor.white
    }
    // MARK: Initializer
    override init(frame: CGRect) {
        let zziming = PublishSubject<Void>()
        
        zzim = { zziming.onNext(()) }
        zzimObservable = zziming
        
        super.init(frame: frame)
        zzimButton.addTarget(self, action: #selector(touchZzim), for: .touchUpInside)
        configureStyle()
        setupConstraints()
        configureRelay()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuration methods
    private func configureStyle() {
        self.contentView.addSubview(goodsImage)
        self.contentView.addSubview(priceStack)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(additionalStack)
        self.contentView.addSubview(separatorView)
        self.contentView.addSubview(zzimButton)
        
        self.isNewView.addSubview(isnewLabel)
        
        self.priceStack.addArrangedSubview(discountPercentageLabel)
        self.priceStack.addArrangedSubview(priceLabel)
    }
    
    private func setupConstraints() {
        goodsImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.width.equalToSuperview().multipliedBy(0.2)
            make.height.equalTo(goodsImage.snp.width).multipliedBy(1)
            make.leading.equalToSuperview().offset(16)
        }
        
        priceStack.snp.makeConstraints { make in
            make.top.equalTo(goodsImage.snp.top).offset(2)
            make.leading.equalTo(goodsImage.snp.trailing).offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(priceStack.snp.bottom).offset(8)
            make.leading.equalTo(priceStack.snp.leading)
            make.trailing.equalToSuperview().offset(-32)
        }
        
        additionalStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalTo(priceStack.snp.leading)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(additionalStack.snp.bottom).offset(20)
            make.height.equalTo(0.2)
            make.leading.trailing.equalToSuperview()
        }
        
        zzimButton.snp.makeConstraints { make in
            make.top.equalTo(goodsImage.snp.top).offset(8)
            make.trailing.equalTo(goodsImage.snp.trailing).offset(-8)
            make.width.equalTo(goodsImage.snp.width).multipliedBy(0.3)
            make.height.equalTo(zzimButton.snp.width).multipliedBy(0.9)
        }
    }
    
    func configure(with viewModel: ViewGoods) {
        
        guard let url = viewModel.image else {
            goodsImage.image = UIImage(systemName: "house")
            return
        }
        goodsImage.kf.setImage(with: URL(string: url))
        
        guard let actualPrice = viewModel.actual_price else {
            priceLabel.text = nil
            return
        }
        
        if let discountPercentage = viewModel.discount_percentage {
            discountPercentageLabel.text = String(discountPercentage) + "%"
        }
        
        if let actualPrice = viewModel.actual_price {
            priceLabel.text = actualPrice.numberStringWithComma()
        }
        
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
                make.top.equalToSuperview().offset(2)
                make.leading.equalToSuperview().offset(5)
                make.centerX.centerY.equalToSuperview()
            }
            additionalStack.addArrangedSubview(isNewView)
        }
        
        guard let sellCount = viewModel.sell_count else {
            return
        }
        
        if sellCount >= 10 {
            sellCountLabel.text = sellCount.numberStringWithComma() + "개 구매중"
            additionalStack.addArrangedSubview(sellCountLabel)
        }
        
        if viewModel.isZzim {
            zzimButton.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
            zzimButton.tintColor = .accentRed
        }
    }

    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isNewView.removeFromSuperview()
        sellCountLabel.removeFromSuperview()
        zzimButton.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        zzimButton.tintColor = .white
        disposeBag = DisposeBag()
    }
}

/**
 사용x) cell의 순서가 바뀌는 이슈가 있음
 */
extension GoodsCell {
    func configureRelay() {
        relayViewModel.asDriver(onErrorJustReturn: ViewGoods(GoodsModel()))
            .drive(onNext: {[weak self] model in
                
                // image
                if let url = model.image {
                    self?.goodsImage.kf.setImage(with: URL(string: url))
                } else {
                    self?.goodsImage.image = UIImage(systemName: "house") // placeholder
                }
                
                // discount percentage
                self?.discountPercentageLabel.text = String(model.discount_percentage ??  0) + "%"
                
                // actual price
                if let actualPrice = model.actual_price {
                    self?.priceLabel.text = actualPrice.numberStringWithComma()
                } else {
                    self?.priceLabel.text = "가격 정보 없음"
                }
                
                // title
                self?.titleLabel.text = model.name ?? "상품 정보 없음"
                
                // is new
                if let isNew = model.is_new {
                    if isNew == true {
                        //self?.isNewView.addSubview(self?.isnewLabel ?? nil)
                        self?.isnewLabel.snp.makeConstraints { make in
                            make.top.equalToSuperview().offset(2)
                            make.leading.equalToSuperview().offset(5)
                            make.centerX.centerY.equalToSuperview()
                        }
                        self?.additionalStack.addArrangedSubview(self!.isNewView)
                    }
                }
                
                if let sellCount = model.sell_count {
                    if sellCount >= 10 {
                        self?.sellCountLabel.text = sellCount.numberStringWithComma() + "개 구매중"
                        self?.additionalStack.addArrangedSubview(self!.sellCountLabel)
                    }
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Button Touch Actions
extension GoodsCell {
    @objc
    func touchZzim() {
        zzim()
    }
}

// MARK: - Remove Zzim Button
extension GoodsCell {
    func removeZzimButton() {
        self.zzimButton.removeFromSuperview()
    }
}

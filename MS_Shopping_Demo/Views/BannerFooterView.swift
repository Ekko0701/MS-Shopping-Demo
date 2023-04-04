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
import RxSwift
import RxCocoa

final class BannerPageLabelDecorationView: UICollectionReusableView {
    static let identifier = "BannerPageLabelDecorationView"
    
    // MARK: Properties
    private var pageCountView = UIView().then {
        $0.backgroundColor = UIColor.systemGray.withAlphaComponent(0.5)
    }
    
    private var pageCountLabel = UILabel().then {
        $0.textColor = .black
    }
    
    private var reuseView = PublishSubject<Void>()
    
    private var disposeBag = DisposeBag()
    
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
        print("-----재사용 준비 입니다------")
        pageCountLabel.text = nil
        self.disposeBag = DisposeBag()
    }
}

extension BannerPageLabelDecorationView {
    private func configureStyle() {
        self.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        self.addSubview(pageCountView)
        self.pageCountView.addSubview(pageCountLabel)
        
        pageCountView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        pageCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(4)
            make.top.equalToSuperview().offset(4)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    func bind(input: Observable<Int>, indexPath: IndexPath, pageNumber: Int) {
        pageCountLabel.text = String(1) + "/" + String(pageNumber)
        input
            .subscribe(onNext: { [weak self] currentPage in
                //print("현재 페이지는 \(currentPage) 입니다.")
                self?.pageCountLabel.text = String(currentPage + 1) + "/" + String(pageNumber)
            }).disposed(by: disposeBag)
    }
}



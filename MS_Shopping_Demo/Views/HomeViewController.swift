//
//  HomeViewController.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import UIKit
import RxViewController
import RxSwift

class HomeViewController: BaseViewController {
    
    // MARK: Properties
    private var collectionView: UICollectionView!
    let viewModel: HomeViewModelType
    
    // MARK: Initilizer
    init(viewModel: HomeViewModelType = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configureStyle()
        setupConstraints()
        setupBindings()
        //self.collectionView.dataSource = self
    }
    
    // MARK: Configuration methods
    override func configureStyle() {
    }
    
    override func setupConstraints() {
    }
}

// MARK: - UICollectionView
extension HomeViewController {
    private func configureCollectionView() {
        
    }
    
    private func generateCollectionViewLayout() {
        
    }
}

// MARK: - Rx Setup
extension HomeViewController {
    func setupBindings() {
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
//        let reload = collectionView.refreshControl?.rx
//            .controlEvent(.valueChanged)
//            .map{_ in ()} ?? Observable.just(())
        
        firstLoad
            .bind(to: viewModel.fetchHome)
            .disposed(by: disposeBag)
        
        viewModel.pushBanners.subscribe { result in
            print(result)
        }.disposed(by: disposeBag)
        
        
    }
}

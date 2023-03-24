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
    private var homeCollectionView: UICollectionView!
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
        configureCollectionView()
        configureStyle()
        setupConstraints()
        setupBindings()
    }
    
    // MARK: Configuration methods
    override func configureStyle() {
    }
    
    override func setupConstraints() {
        self.view.addSubview(homeCollectionView)
        
        homeCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView
extension HomeViewController {
    private func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = .clear
        
        // Register
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.identifier)
        collectionView.register(GoodsCell.self, forCellWithReuseIdentifier: GoodsCell.identifier)
        
        homeCollectionView = collectionView
    }
    
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                //item.contentInsets.trailing = 2
                //item.contentInsets.bottom = 16
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .paging
                
                return section
            } else {
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                item.contentInsets.trailing = 16
                item.contentInsets.bottom = 16
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.3)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets.leading = 16
                
                return section
            }
        }
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

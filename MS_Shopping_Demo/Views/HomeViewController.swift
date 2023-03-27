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
    
    enum HomeSection: CaseIterable {
        case banner
        case goods
    }
    
    typealias HomeDataSource = UICollectionViewDiffableDataSource<HomeSection, AnyHashable>
    var dataSource: HomeDataSource! = nil
    var snapshot = NSDiffableDataSourceSnapshot<HomeSection, AnyHashable>()
    
    var isLoadedHome: Bool = false
    
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
        
        snapshot.appendSections([.banner, .goods])
        
        self.view.backgroundColor = .white
        configureCollectionView()
        configureStyle()
        
        setupBindings()
        setupConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dataSource.apply(snapshot, animatingDifferences: true)
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
        collectionView.dataSource = dataSource
        
        homeCollectionView = collectionView
        
        homeCollectionView.delegate = self
        
        dataSource = setupDiffableDataSource()
        dataSource.apply(snapshot, animatingDifferences: false)
        homeCollectionView.dataSource = dataSource
    }
    
    /** Compositional 레이아웃 생성*/
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.orthogonalScrollingBehavior = .paging
                
                return section
            } else {
                
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
        }
    }
    
    /** DiffableDataSource 생성 */
    private func setupDiffableDataSource() -> UICollectionViewDiffableDataSource<HomeSection, AnyHashable> {
        var homedDataSource: UICollectionViewDiffableDataSource<HomeSection, AnyHashable>
        homedDataSource = UICollectionViewDiffableDataSource<HomeSection, AnyHashable>(collectionView: homeCollectionView, cellProvider: { collectionView, indexPath, item in
            if let bannerItem = item as? ViewBanner {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.identifier, for: indexPath) as? BannerCell else { return UICollectionViewCell() }
                //cell.configure(with: bannerItem) // (1)
                cell.relayViewModel.accept(bannerItem) // (2) Rx를 이용해 cell 내부에서 바인딩
                
                return cell
            } else if let goodsItem = item as? ViewGoods {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoodsCell.identifier, for: indexPath) as? GoodsCell else { return UICollectionViewCell() }
                
                cell.configure(with: goodsItem) // (1)
                //cell.relayViewModel.accept(goodsItem)
                cell.zzimObservable
                    .map{ (goodsItem) }
                   // .bind(to: self.viewModel.touchZzimButton)
                    .do(onNext: {[weak self] _ in
                        self?.snapshot.deleteSections([.goods]) // 이거 매우매우 비 효율적.. ;;
                        self?.snapshot.appendSections([.goods])
                    })
                        .subscribe(onNext: { self.viewModel.touchZzimButton.onNext($0)})
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            
            return nil
        })
        
        return homedDataSource
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
        
        viewModel.activated.bind { [weak self] isActie in
            self?.isLoadedHome = isActie
        }.disposed(by: disposeBag)
        
        viewModel.pushBanners.bind{ [weak self] value in
            self?.snapshot.appendItems(value, toSection: .banner)
            self?.snapshot.reloadSections([.banner])
            self?.dataSource.apply(self!.snapshot)
        }.disposed(by: disposeBag)
        
        viewModel.pushGoods.bind{ [weak self] value in
            self?.snapshot.appendItems(value, toSection: .goods)
            self?.snapshot.reloadSections([.banner, .goods])
            self?.dataSource.apply(self!.snapshot, animatingDifferences: false)

        }.disposed(by: disposeBag)
    
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.height
        
        if (offsetY > contentHeight - visibleHeight) && !isLoadedHome{
            viewModel.fetchNewGoods.onNext(Void())
        
        }
    }
}

// MARK: - 페이징
extension HomeViewController {
    func loadNewGoods() {
        
    }
}


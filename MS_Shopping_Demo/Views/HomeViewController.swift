//
//  HomeViewController.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import UIKit
import RxViewController
import RxSwift
import RxCocoa


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
        
        self.view.backgroundColor = .white
        configureCollectionView()
        configureStyle()
        
        setupBindings()
        setupConstraints()
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
        let layout = generateLayout()
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        
        collectionView.backgroundColor = .clear
        
        // Register
        collectionView.register(BannerCell.self, forCellWithReuseIdentifier: BannerCell.identifier)
        collectionView.register(GoodsCell.self, forCellWithReuseIdentifier: GoodsCell.identifier)
        
        collectionView.register(BannerPageLabelDecorationView.self, forSupplementaryViewOfKind: ElementKind.sectionFooter, withReuseIdentifier: BannerPageLabelDecorationView.identifier)
        
        collectionView.dataSource = dataSource
        
        // Init
        homeCollectionView = collectionView
        
        // Attach
        homeCollectionView.delegate = self
        
        // Refresh Control
        homeCollectionView.refreshControl = UIRefreshControl()
        
        // DataSource
        
        snapshot.appendSections(HomeSection.allCases)
        
        dataSource = setupDiffableDataSource()
        dataSource.apply(snapshot, animatingDifferences: false)
        
        
        homeCollectionView.dataSource = dataSource
        
        
    }
    
    /// Compositional Layout 생성
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            
            if sectionNumber == 0 {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.7)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                section.visibleItemsInvalidationHandler = { [weak self] visibleItems, contentOffset, environment in
                    guard let self = self else { return }
                    
                    // 비교용 - Device의 Screen 크기
                        //print("=== Screen Width/Height :", UIScreen.main.bounds.width, "/", UIScreen.main.bounds.height)

                        // ✅ contentOffset은 CollectionView의 bound를 기준으로 Scroll 결과 보여지는 컨텐츠의 Origin을 나타냄
                        // 배너 및 목록화면의 경우, Scroll하면 어디서 클릭해도 0부터 시작
                        // 상세화면의 경우, Scroll하면 어디서 클릭해도 약 -30부터 시작 (기기마다 다름, CollectionView의 bound를 기준으로 cell(이미지)의 leading이 왼쪽 (-30)에 위치하므로 음수임)
                        //print("OffsetX :", contentOffset.x)

                        // ✅ environmnet는 collectionView layout 관련 정보를 담고 있음
                        // environment.container.contentSize는 CollectionView 중에서 현재 Scroll된 Group이 화면에 보이는 높이를 나타냄
                        //print("environment Width :", environment.container.contentSize.width)   // Device의 스크린 너비와 동일
                        //print("environment Height :", environment.container.contentSize.height) // Horizontal Scroll하면 스크린 너비와 같고, Vertical Scroll하면 그보다 커짐

                        let bannerIndex = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))  // 음수가 되는 것을 방지하기 위해 max 사용
                        //print(bannerIndex)
                    if environment.container.contentSize.height == (environment.container.contentSize.width * 0.7) {  // ❗Horizontal Scroll 하는 조건
                            //self.currentBannerPage.onNext(bannerIndex)  // 클로저가 호출될 때마다 pageControl의 currentPage로 값을 보냄
                            print("값 전송")
                            self.viewModel.currentBannerPage.onNext(bannerIndex)
                        }
                }
                
                section.orthogonalScrollingBehavior = .paging
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: -40, trailing: 0)
                
                let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40))
        
                let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerFooterSize, elementKind: ElementKind.sectionFooter, alignment: .bottom)
                
                sectionFooter.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: -40, trailing: 0)
                sectionFooter.pinToVisibleBounds = true
                
                section.boundarySupplementaryItems = [sectionFooter]
                
                return section
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                
                return section
            }
        }
    }
    
    private func configureBannerLabel() {
        
    }
    
    /// DiffableDataSource 생성
    private func setupDiffableDataSource() -> HomeDataSource {
        var homedDataSource: HomeDataSource
        homedDataSource = HomeDataSource(collectionView: homeCollectionView, cellProvider: { collectionView, indexPath, item in
            if let bannerItem = item as? ViewBanner {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BannerCell.identifier, for: indexPath) as? BannerCell else { return UICollectionViewCell() }
                cell.configure(with: bannerItem) // (1)
                //cell.relayViewModel.accept(bannerItem) // (2) Rx를 이용해 cell 내부에서 바인딩
                
                return cell
            } else if let goodsItem = item as? ViewGoods {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoodsCell.identifier, for: indexPath) as? GoodsCell else { return UICollectionViewCell() }
                
                cell.configure(with: goodsItem) // (1)
                //cell.relayViewModel.accept(goodsItem) // (2)
                
                /// 찜 버튼 터치 
                cell.zzimObservable
                    .map{ (goodsItem) }
                   // .bind(to: self.viewModel.touchZzimButton)
                    .do(onNext: {[weak self] _ in
                        //self?.snapshot.deleteSections([.goods]) // 이거 매우매우 비 효율적.. ;;
                        //self?.snapshot.appendSections([.goods])
                    })
                        .subscribe(onNext: { self.viewModel.touchZzimButton.onNext($0)})
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            
            return nil
        })
        
        // MARK: - SupplementaryViewProvider
        homedDataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            if kind == ElementKind.sectionFooter {
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: ElementKind.sectionFooter, withReuseIdentifier: BannerPageLabelDecorationView.identifier, for: indexPath) as? BannerPageLabelDecorationView else { return UICollectionReusableView() }
                guard let self = self else { return UICollectionReusableView() }

                footerView.bind(input: self.viewModel.currentBannerPage.asObservable(), indexPath: indexPath, pageNumber: 3)
                
                return footerView
            }
            
            return nil
        }
        
        return homedDataSource
    }
}



// MARK: - Rx Setup
extension HomeViewController {
    func setupBindings() {
        let firstLoad = rx.viewWillAppear
            .take(1)
            .map { _ in () }
        
        let reload = homeCollectionView.refreshControl?.rx
            .controlEvent(.valueChanged)
            .map{_ in ()} ?? Observable.just(())
        
        Observable.merge([firstLoad, reload])
            .bind(to: viewModel.fetchHome)
            .disposed(by: disposeBag)
        
        viewModel.activated
            .map { !$0 }
            .do(onNext: { [weak self] finished in
                if finished {
                    self?.homeCollectionView.refreshControl?.endRefreshing()
                }
            })
            .bind { [weak self] isActiv in
            self?.isLoadedHome = !isActiv
        }.disposed(by: disposeBag)
        
        viewModel.pushBanners.bind{ [weak self] value in
            self?.snapshot.appendItems(value, toSection: .banner)
            //self?.snapshot.reloadSections([.banner])
            self?.dataSource.apply(self!.snapshot)
        }.disposed(by: disposeBag)
        
        viewModel.pushGoods.bind{ [weak self] value in
            self?.snapshot.deleteSections([.goods])
            self?.snapshot.appendSections([.goods])
            self?.snapshot.appendItems(value, toSection: .goods)
            //self?.snapshot.reloadSections([.goods])
            self?.dataSource.apply(self!.snapshot, animatingDifferences: false)

        }.disposed(by: disposeBag)
    
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("스크롤됨")
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.height
        
        if (offsetY > contentHeight - visibleHeight) && !isLoadedHome {
            viewModel.fetchNewGoods.onNext(Void())
        }
    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        guard let collectionView = scrollView as? UICollectionView else { return }
//
//        let layout = collectionView.collectionViewLayout
//        let width = layout.collectionViewContentSize.width / CGFloat(3) // 배너의 개수로 설정
//
//        let targetX = targetContentOffset.pointee.x
//        let page = Int((targetX + collectionView.contentInset.left) / width)
//
//        print("현재 보이는 셀의 인덱스: \(page)")
//    }
//
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//            guard let collectionView = scrollView as? UICollectionView else {
//                return
//            }
//
//            let layout = collectionView.collectionViewLayout
//            let width = layout.collectionViewContentSize.width / CGFloat(3)
//
//            let targetX = scrollView.contentOffset.x
//            let page = Int((targetX + collectionView.contentInset.left) / width)
//
//            print("현재 보이는 셀의 인덱스: \(page)")
//        }
}


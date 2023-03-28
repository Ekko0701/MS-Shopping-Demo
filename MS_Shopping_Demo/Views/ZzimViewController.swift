//
//  ZzimViewController.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import UIKit

class ZzimViewController: BaseViewController {

    // MARK: - Properties
    private var zzimCollectionView: UICollectionView!
    let viewModel: ZzimViewModelType
    
    enum ZzimSection: CaseIterable {
        case goods
    }
    
    typealias ZzimDataSource = UICollectionViewDiffableDataSource<ZzimSection, ViewGoods>
    var dataSource: ZzimDataSource! = nil
    var snapshot = NSDiffableDataSourceSnapshot<ZzimSection, ViewGoods>()
    
    // MARK: - Initializer
    init(viewModel: ZzimViewModelType = ZzimViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureCollectionView()
        setupBindings()
        setupConstraints()
    }
    
    // MARK: - Configure & Setup methods
    override func configureStyle() {
        view.backgroundColor = .white
    }
    
    override func setupConstraints() {
        // Add Subviews
        self.view.addSubview(zzimCollectionView)
        
        // Setup constraints
        zzimCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UICollectionView
extension ZzimViewController {
    private func configureCollectionView() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: generateLayout())
        collectionView.backgroundColor = .clear
        
        // Register
        collectionView.register(GoodsCell.self, forCellWithReuseIdentifier: GoodsCell.identifier)
        
        zzimCollectionView = collectionView
        
        dataSource = setupDiffableDataSource()
        snapshot.appendSections([.goods])
        dataSource.apply(snapshot, animatingDifferences: false)
        zzimCollectionView.dataSource = dataSource
        
    }
    
    private func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) ->
            NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            return section
        }
    }
    
    private func setupDiffableDataSource() -> ZzimDataSource {
        var zzimDataSource: ZzimDataSource
        zzimDataSource = ZzimDataSource(collectionView: zzimCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GoodsCell.identifier, for: indexPath) as? GoodsCell else { return UICollectionViewCell() }
            cell.configure(with: itemIdentifier)
            cell.removeZzimButton()
            
            return cell
            
        })
        return zzimDataSource
    }
}

// MARK: - Rx Setup
extension ZzimViewController {
    func setupBindings() {
        let firstLoad = rx.viewWillAppear
            .map { _ in () }
        
        firstLoad
            .bind(to: viewModel.fetchZzimGoods)
            .disposed(by: disposeBag)
        
        viewModel.pushZzimGoods.bind { [weak self] value in
            self?.snapshot.deleteSections([.goods])
            self?.snapshot.appendSections([.goods])
            self?.snapshot.appendItems(value, toSection: .goods)
            self?.snapshot.reloadSections([.goods])
            self?.dataSource.apply(self!.snapshot, animatingDifferences: false)
        }.disposed(by: disposeBag)
    }
}

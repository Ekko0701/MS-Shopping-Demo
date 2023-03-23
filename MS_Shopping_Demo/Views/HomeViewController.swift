//
//  HomeViewController.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import UIKit

class HomeViewController: BaseViewController {
    
    // MARK: Properties
    private lazy var collectionView: UICollectionView! = nil
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        configureStyle()
        setupConstraints()
        
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

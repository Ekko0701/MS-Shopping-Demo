//
//  BaseViewController.swift
//  MS_Shopping_Demo
//
//  Created by Ekko on 2023/03/23.
//

import Foundation
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxViewController

//MARK: - Property
class BaseViewController: UIViewController {
    
    // MARK: Properties
    lazy private(set) var className: String = {
        return type(of: self).description().components(separatedBy: ".").last ?? ""
    }()
    
    // MARK: Initializing
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    deinit {
    }
    
    // MARK: Rx
    var disposeBag = DisposeBag()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureStyle()
        setupConstraints()
    }
    
    /** View 스타일 설정 */
    func configureStyle() {
        // Override point
    }
    
    /** Constraints 설정 */
    func setupConstraints() {
        // Override point
    }
}

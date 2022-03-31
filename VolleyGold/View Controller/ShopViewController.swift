//
//  ShopViewController.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit
import StoreKit

class ShopViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PurchaseManager.shared.delegate = self
        
        if PurchaseManager.shared.purchasedProduct != nil {
            buyButton.setTitle("Purchased", for: .normal)
            buyButton.isUserInteractionEnabled = false
            buyButton.backgroundColor = .systemGray
        }
        else {
            PurchaseManager.shared.requestProducts()
        }
        
        configureViews()
        configureEvents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.flashScrollIndicators()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(shopLabel)
        shopLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40.width)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(shopLabel.snp.bottom).offset(10)
        }
        
        view.addSubview(buyButton)
        buyButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50.width)
            make.width.equalTo(200.width)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(restoreButton)
        restoreButton.snp.makeConstraints { make in
            make.top.equalTo(buyButton.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.bottom.equalTo(buyButton.snp.top).offset(-10)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(40.height)
            make.left.top.equalToSuperview().offset(20.height)
        }
        view.bringSubviewToFront(closeButton)
    }
    
    func configureEvents() {
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        buyButton.addTarget(self, action: #selector(buy), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restore), for: .touchUpInside)
    }
    
    @objc func buy() {
        PurchaseManager.shared.buyProduct()
        
        buyButton.setTitle("Processing", for: .normal)
        buyButton.isUserInteractionEnabled = false
        buyButton.backgroundColor = .systemGray
    }
    
    @objc func restore() {
        PurchaseManager.shared.restorePurchases()
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var models: [SkinType] = SkinType.purchasable
    
    lazy var shopLabel: UILabel = {
        let view = UILabel()
        view.text = "Character's Pack"
        view.font = UIFont(name: "Chalkduster", size: 20)
        return view
    }()
    
    lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.text = "Buy Character's Pack to unlock all characters below!"
        view.font = UIFont(name: "Chalkduster", size: 14)
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 150.height, height: 150.height)
        layout.minimumInteritemSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .systemBackground
        view.dataSource = self
        view.delegate = self
        view.register(ProductCell.self, forCellWithReuseIdentifier: "Product")
        return view
    }()
    
    lazy var buyButton: UIButton = {
        let view = UIButton()
        view.setTitle("Buy", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name: "Chalkduster", size: 20)
        view.layer.cornerRadius = 10
        view.contentEdgeInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .systemGray
        return view
    }()
    
    lazy var restoreButton: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("Restore", for: .normal)
        view.setTitleColor(.systemGray2, for: .normal)
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "close"), for: .normal)
        return view
    }()
}

extension ShopViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Product", for: indexPath) as! ProductCell
        cell.model = models[indexPath.row].product
        return cell
    }
}

extension ShopViewController: PurchaseManagerDelegate {
    internal func purchaseManager(didFinishProductRequestWith products: [SKProduct]?, isSuccess: Bool) {
        DispatchQueue.main.async { [unowned self] in
            if isSuccess {
                buyButton.isUserInteractionEnabled = true
                buyButton.backgroundColor = .brown
            } else {
                buyButton.isUserInteractionEnabled = false
                buyButton.backgroundColor = .systemGray
            }
        }
    }
    
    func purchaseManager(didUpdatePurchaseStatusOf productType: ProductType?) {
        if productType != nil {
            buyButton.setTitle("Purchased", for: .normal)
            buyButton.isUserInteractionEnabled = false
            buyButton.backgroundColor = .systemGray
        } else {
            buyButton.setTitle("Buy", for: .normal)
            buyButton.isUserInteractionEnabled = true
            buyButton.backgroundColor = .brown
        }
    }
    
    func purchaseManager(didFailWithError error: Error?) {
        showAlert(title: "Failed", message: error?.localizedDescription)
        buyButton.setTitle("Buy", for: .normal)
        buyButton.isUserInteractionEnabled = true
        buyButton.backgroundColor = .brown
    }
    
    func purchaseManagerRestoreFinished() {
        showAlert(title: "Restore finished", message: "Your purchase status is updated.")
    }
}


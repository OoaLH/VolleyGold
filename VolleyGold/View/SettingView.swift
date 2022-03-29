//
//  SettingView.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-27.
//

import UIKit

class SettingView: UIView {
    var userDefaultKey: String
    var selectedSkin: String
    var promotionText: String = ""
    
    let models: [SkinType]
    
    init(userDefaultKey: String) {
        self.userDefaultKey = userDefaultKey
        self.selectedSkin = UserDefaults.standard.string(forKey: userDefaultKey) ?? "pig"
        
        if PurchaseManager.shared.purchasedProduct != nil {
            models = SkinType.allCases
        } else {
            models = [.pig]
            promotionText = " - Buy Character's Pack to unlock more characters!"
        }
        
        super.init(frame: .zero)
        
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews() {
        backgroundColor = .systemBackground
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(120.height)
        }
    }
    
    func confirm() {
        UserDefaults.standard.set(selectedSkin, forKey: userDefaultKey)
    }
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.text = userDefaultKey + promotionText
        view.font = UIFont(name: "Chalkduster", size: 14)
        view.textAlignment = .left
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100.height, height: 100.height)
        layout.minimumInteritemSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .systemBackground
        view.dataSource = self
        view.delegate = self
        view.register(ProductCell.self, forCellWithReuseIdentifier: "Product")
        return view
    }()
}

extension SettingView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Product", for: indexPath) as! ProductCell
        cell.model = models[indexPath.row].product
        if cell.model?.name == selectedSkin {
            cell.select()
        } else {
            cell.deselect()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProductCell
        selectedSkin = cell.model?.name ?? "pig"
        collectionView.reloadData()
    }
}

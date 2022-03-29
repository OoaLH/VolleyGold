//
//  ProductCell.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-27.
//

import UIKit

class ProductCell: UICollectionViewCell {
    var model: SkinProduct? {
        didSet {
            imageView.image = model?.image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemFill.cgColor
        layer.cornerRadius = 10
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select() {
        layer.borderColor = UIColor.systemYellow.cgColor
        layer.borderWidth = 2
    }
    
    func deselect() {
        layer.borderColor = UIColor.systemFill.cgColor
        layer.borderWidth = 1
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
}

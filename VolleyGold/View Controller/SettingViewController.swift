//
//  SettingViewController.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit

class SettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureEvents()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    func configureViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(settingLabel)
        settingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40.width)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-40.width)
            make.width.equalTo(200.width)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(40.height)
            make.left.top.equalToSuperview().offset(20.height)
        }
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.bottom.equalTo(confirmButton.snp.top).offset(-10)
            make.top.equalTo(settingLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        let contentView = UIView()
        contentView.addSubview(local1View)
        contentView.addSubview(local2View)
        contentView.addSubview(onlineView)
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(view).offset(40)
            make.right.equalTo(view).offset(-40)
        }
        
        local1View.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        
        local2View.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(local1View.snp.bottom)
        }
        
        onlineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(local2View.snp.bottom)
        }
        
        view.bringSubviewToFront(closeButton)
    }
    
    func configureEvents() {
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
    }
    
    @objc func confirm() {
        local1View.confirm()
        local2View.confirm()
        onlineView.confirm()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func close() {
        if PurchaseManager.shared.purchasedProduct == nil {
            confirm()
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    lazy var models: [[SkinType]] = {
        if PurchaseManager.shared.purchasedProduct == .skins {
            return [SkinType.purchasable, SkinType.purchasable, SkinType.purchasable]
        } else {
            return [[.pig], [.pig], [.pig]]
        }
    }()
    
    lazy var settingLabel: UILabel = {
        let view = UILabel()
        view.text = "Settings"
        view.font = UIFont(name: "Chalkduster", size: 20)
        return view
    }()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        
        return view
    }()
    
    lazy var local1View = SettingView(userDefaultKey: "Player 1")
    
    lazy var local2View = SettingView(userDefaultKey: "Player 2")
    
    lazy var onlineView = SettingView(userDefaultKey: "Online")
    
    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "close"), for: .normal)
        return view
    }()
    
    lazy var confirmButton: UIButton = {
        let view = UIButton()
        view.setTitle("Confirm", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name: "Chalkduster", size: 20)
        view.layer.cornerRadius = 10
        view.contentEdgeInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        view.backgroundColor = .brown
        return view
    }()
}

//
//  HomeViewController.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit
import GameKit
import StoreKit
import SnapKit
import Lottie

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViews()
        configureEvents()
        
        NetworkMonitor.shared.start()
        
        GameCenterManager.shared.viewController = self
        GameCenterManager.shared.authenticate()
        
        GKAccessPoint.shared.location = .bottomLeading
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GKAccessPoint.shared.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        GKAccessPoint.shared.isActive = false
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    func configureViews() {
        view.backgroundColor = .brown
        
        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10.height
        stackView.addArrangedSubview(onlineButton)
        stackView.addArrangedSubview(localButton)
        stackView.addArrangedSubview(singleButton)
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40.width)
            make.centerY.equalToSuperview()
            make.width.equalTo(200.width)
        }
        
        view.addSubview(spinView)
        spinView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(shopButton)
        shopButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-40.width)
            make.top.equalToSuperview().offset(40.width)
            make.width.height.equalTo(40.width)
        }
        
        shopButton.addSubview(shopAnimationView)
        shopAnimationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        shopAnimationView.play()
        
        view.addSubview(settingButton)
        settingButton.snp.makeConstraints { make in
            make.right.equalTo(shopButton.snp.left).offset(-10)
            make.top.equalToSuperview().offset(40.width)
            make.width.height.equalTo(40.width)
        }
        
        settingButton.addSubview(settingAnimationView)
        settingAnimationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        settingAnimationView.play()
        
        view.addSubview(instructionButton)
        instructionButton.snp.makeConstraints { make in
            make.right.equalTo(settingButton.snp.left).offset(-10)
            make.top.equalToSuperview().offset(40.width)
            make.width.height.equalTo(40.width)
        }
        
        instructionButton.addSubview(instructionAnimationView)
        instructionAnimationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        instructionAnimationView.play()
    }
    
    func configureEvents() {
        onlineButton.addTarget(self, action: #selector(onlineGaming), for: .touchUpInside)
        localButton.addTarget(self, action: #selector(localGaming), for: .touchUpInside)
        singleButton.addTarget(self, action: #selector(singleGaming), for: .touchUpInside)
        instructionButton.addTarget(self, action: #selector(instruction), for: .touchUpInside)
        shopButton.addTarget(self, action: #selector(shop), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(setting), for: .touchUpInside)
    }
    
    func checkIfUsingCellular(_ completionHandler: (() -> Void)? = nil) {
        if NetworkMonitor.shared.usingCellular {
            let alert = UIAlertController(title: "You are using cellular data", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "Continue", style: .default) { _ in
                completionHandler?()
            }
            alert.addAction(ok)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(cancel)
            alert.preferredAction = ok
            present(alert, animated: true, completion: nil)
        } else if NetworkMonitor.shared.reachable {
            completionHandler?()
        } else {
            showAlert(title: "Can't connect to Internet", message: "Please check your network settings. Your Internet connection will affect online games, uploading scores to Game Center, and access to leaderboard.")
        }
    }
    
    func dismissWithError(error: ConnectionError?) {
        dismiss(animated: true) { [unowned self] in
            showAlert(title: "Disconnected from game", message: error?.localizedDescription)
        }
    }
    
    @objc func onlineGaming() {
        checkIfUsingCellular { [unowned self] in
            spinView.startAnimating()
            view.isUserInteractionEnabled = false
            
            GameCenterManager.shared.authenticate { [unowned self] in
                spinView.stopAnimating()
                view.isUserInteractionEnabled = true
                GameCenterManager.shared.presentMatchmaker()
            }
        }
    }
    
    @objc func localGaming() {
        let vc = GameViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func singleGaming() {
        let vc = SingleGameViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func instruction() {
        let vc = InstructionViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func shop() {
        let vc = ShopViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func setting() {
        let vc = SettingViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    lazy var instructionButton = UIButton()
    
    lazy var settingButton = UIButton()
    
    lazy var shopButton = UIButton()
    
    lazy var instructionAnimationView: AnimationView = {
        let view = AnimationView(name: "question")
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var settingAnimationView: AnimationView = {
        let view = AnimationView(name: "gear")
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var shopAnimationView: AnimationView = {
        let view = AnimationView(name: "shop")
        view.loopMode = .loop
        view.backgroundBehavior = .pauseAndRestore
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var backgroundView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "home")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var onlineButton: UIButton = {
        let view = UIButton()
        view.setTitle("online", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name: "Chalkduster", size: 20)
        view.backgroundColor = .brown
        view.layer.cornerRadius = 10
        view.contentEdgeInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        return view
    }()
    
    lazy var localButton: UIButton = {
        let view = UIButton()
        view.setTitle("local", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name: "Chalkduster", size: 20)
        view.backgroundColor = .brown
        view.layer.cornerRadius = 10
        view.contentEdgeInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        return view
    }()
    
    lazy var singleButton: UIButton = {
        let view = UIButton()
        view.setTitle("single", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont(name: "Chalkduster", size: 20)
        view.backgroundColor = .brown
        view.layer.cornerRadius = 10
        view.contentEdgeInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        return view
    }()
    
    lazy var spinView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.color = .brown
        return view
    }()
}

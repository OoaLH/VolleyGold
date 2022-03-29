//
//  InstructionViewController.swift
//  VolleyGold
//
//  Created by Yifan Zhang on 2022-03-26.
//

import UIKit
import SnapKit

class InstructionViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(instructionView)
        instructionView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(50.width)
            make.top.equalToSuperview().offset(50.width)
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(40.height)
            make.left.top.equalToSuperview().offset(20.height)
        }
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var instructionView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.backgroundColor = .systemBackground
        let text = "How to play:\n\n1. Login to Game Center to play online or submit your score.\n\n2. Or just play locally with your friend.\n\n3. Press left/right button to move and press upper button jump.\n\n4. Try your best to get the gold into your basket.\n\n5. Enjoy!\n\nQ&A:\n\nQ: Failed to login to Game Center?\nA: Go to Settings > Game Center, and enable Game Center.\n\nQ: Can't receive invitation?\nA: Go to Settings > Notifications > Games, and enable the notification. If you are inviting a friend, make sure your friend has enabled the Game Center notification.\n\nQ: Don't have any friends to invite?\nA: Leave the second player slot empty and press start. You will be paired to another player automatically.\n\nQ: Any other questions?\nA: Feel free to contact zhangyifansugar@gmail.com.\n\nGithub here."
        view.font = UIFont(name: "Chalkduster", size: 20)
        view.addHyperLinksToText(originalText: text, hyperLinks: ["zhangyifansugar@gmail.com": "mailto:zhangyifansugar@gmail.com", "here": "https://github.com/OoaLH"])
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "close"), for: .normal)
        return view
    }()
}

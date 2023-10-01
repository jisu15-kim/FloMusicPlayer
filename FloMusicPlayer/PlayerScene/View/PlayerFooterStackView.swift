//
//  PlayerFooterStackView.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/30.
//

import UIKit

class PlayerFooterStackView: UIStackView {
    //MARK: - Properties
    let snsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "instagram_logo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var recommandMusicButton = self.getCapsuleButton(title: "유사곡")
    let playlistButton = PlayerControlButtonType.playList.getButton
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.axis = .horizontal
        self.distribution = .equalCentering
        self.alignment = .center
        self.setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        [snsButton, recommandMusicButton, playlistButton].forEach {
            self.addArrangedSubview($0)
        }
        
        self.snsButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        self.playlistButton.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
    }
    
    //MARK: - Methods
    private func getCapsuleButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .black
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.tintColor = .white
        
        let dummyLabel: UILabel = {
            let label = UILabel()
            label.text = title
            label.textAlignment = .center
            label.sizeToFit()
            return label
        }()
        
        button.snp.makeConstraints {
            $0.width.equalTo(dummyLabel.frame.width + 15)
            $0.height.equalTo(30)
        }
        
        button.layer.cornerRadius = 30 / 2
        button.clipsToBounds = true
        
        return button
    }
}

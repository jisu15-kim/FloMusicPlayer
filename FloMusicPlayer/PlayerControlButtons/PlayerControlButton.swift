//
//  PlayButton.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/26.
//

import UIKit

class PlayerControlButton: UIButton {
    //MARK: - Properties
    var handler: (() -> Void)?
    
    //MARK: - Lifecycle
    init(buttonType: PlayerControlButtonType, handler: (() -> Void)? = nil) {
        self.handler = handler
        super.init(frame: .zero)
        self.setImage(buttonType.buttonImage, for: .normal)
        self.addTarget(self, action: #selector(didButtonTapped), for: .touchUpInside)
        self.tintColor = .white
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    @objc private func didButtonTapped() {
        print("button Tapped")
        print(MusicPlayer.shared.player?.currentItem?.duration)
    }
}

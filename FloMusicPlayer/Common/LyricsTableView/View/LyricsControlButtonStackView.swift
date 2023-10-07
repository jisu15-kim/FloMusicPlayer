//
//  LyricsControlButtonStackView.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/05.
//

import UIKit

enum ControlButtonStatus {
    case enable
    case disable
    
    var tintColor: UIColor {
        switch self {
        case .enable: return .systemIndigo
        case .disable: return .darkGray
        }
    }
}

class LyricsControlButtonStackView: UIStackView {
    //MARK: - Properties
    let scrollToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "scope"), for: .normal)
        return button
    }()
    
    //MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        self.addArrangedSubview(self.scrollToggleButton)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
}

//
//  PlayerControlButtonType.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/26.
//

import UIKit

/// 버튼 모음
enum PlayerControlButtonType {
    /// 재생 버튼
    case play
    /// 이전곡 버튼
    case backward
    /// 다음곡 버튼
    case forward
    /// 반복 버튼
    case `repeat`
    /// 재생 순서 버튼
    case playOrder
    
    /// 버튼의 이미지
    var buttonImage: UIImage? {
        switch self {
        case .play:
            return UIImage(systemName: "play.fill", withConfiguration: imageConfig)
        case .backward:
            return UIImage(systemName: "backward.end.fill", withConfiguration: imageConfig)
        case .forward:
            return UIImage(systemName: "forward.end.fill", withConfiguration: imageConfig)
        case .repeat:
            return UIImage(systemName: "repeat", withConfiguration: imageConfig)
        case .playOrder:
            return UIImage(systemName: "shuffle", withConfiguration: imageConfig)
        }
    }
    
    /// 버튼 image의 config - 사이즈
    var imageConfig: UIImage.SymbolConfiguration {
        switch self {
        case .play:
            return UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        case .backward:
            return UIImage.SymbolConfiguration(pointSize: 25, weight: .thin)
        case .forward:
            return UIImage.SymbolConfiguration(pointSize: 25, weight: .thin)
        case .repeat:
            return UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        case .playOrder:
            return UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        }
    }
    
    /// 버튼 인스턴스
    var getButton: UIButton {
        return PlayerControlButton(buttonType: self)
    }
}

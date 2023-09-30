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
    /// 재생목록 버튼
    case playList
    
    /// 버튼의 이미지
    func getButtonImage(playStatus: PlayStatus) -> UIImage? {
        switch self {
        case .play:
            return UIImage(systemName: playStatus.iconImageName, withConfiguration: imageConfig)
        case .backward:
            return UIImage(systemName: "backward.end.fill", withConfiguration: imageConfig)
        case .forward:
            return UIImage(systemName: "forward.end.fill", withConfiguration: imageConfig)
        case .repeat:
            return UIImage(systemName: "repeat", withConfiguration: imageConfig)
        case .playOrder:
            return UIImage(systemName: "shuffle", withConfiguration: imageConfig)
        case .playList:
            return UIImage(systemName: "text.append", withConfiguration: imageConfig)
        }
    }
    
    /// 버튼 image의 config - 사이즈
    var imageConfig: UIImage.SymbolConfiguration {
        switch self {
        case .play:
            return UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        case .backward, .forward, .playList:
            return UIImage.SymbolConfiguration(pointSize: 25, weight: .thin)
        case .repeat, .playOrder:
            return UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        }
    }
    
    /// 버튼 인스턴스
    var getButton: UIButton {
        return PlayerControlButton(buttonType: self)
    }
    
    func buttonAction(playStatus: PlayStatus) {
        switch self {
        case .play:
            playStatus.handler?()
        case .backward:
            print("뒤로가기")
        case .forward:
            print("앞으로 가기")
        case .repeat:
            print("반복")
        case .playOrder:
            print("PLAY ORDER")
        case .playList:
            print("PlayList")
        }
    }
}

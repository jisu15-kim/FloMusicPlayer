//
//  LyricsTypeConfig.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/03.
//

import UIKit

enum LyricsTypeConfig {
    case inPlayerView
    case inLyricView
}

extension LyricsTypeConfig {
    /// 가사 셀의 높이
    var heightForRowAt: CGFloat {
        switch self {
        case .inPlayerView: return 20
        case .inLyricView: return 25
        }
    }
    
    /// 스크롤 허용 여부
    var isScrollEnable: Bool {
        switch self {
        case .inPlayerView: return false
        case .inLyricView: return true
        }
    }
    
    /// 텍스트 폰트
    var lyricFont: UIFont {
        switch self {
        case .inPlayerView: return .systemFont(ofSize: 14, weight: .regular)
        case .inLyricView: return .systemFont(ofSize: 16, weight: .regular)
        }
    }
    
    /// 텍스트 정렬
    var textAlighment: NSTextAlignment {
        switch self {
        case .inPlayerView: return .center
        case .inLyricView: return .left
        }
    }
    
    /// 우측 버튼 보이는 여부
    var isShowControlButton: Bool {
        switch self {
        case .inPlayerView: return false
        case .inLyricView: return true
        }
    }
}

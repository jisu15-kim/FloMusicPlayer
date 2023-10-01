//
//  PlayStatus.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/30.
//

import UIKit

enum PlayStatus: Float {
    case playing
    case notPlaying
    
    var iconImageName: String {
        switch self {
        case .playing: return "pause.fill"
        case .notPlaying: return "play.fill"
        }
    }
    
    var handler: (() -> Void)? {
        switch self {
        case .playing:
            return MusicPlayer.shared.pause
        case .notPlaying:
            return MusicPlayer.shared.resume
        }
    }
}

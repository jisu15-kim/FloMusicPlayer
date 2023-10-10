//
//  PlayerViewModel.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/01.
//

import UIKit
import RxRelay

enum LikeButtonStatus {
    case enable
    case disable
    
    var buttonImage: UIImage? {
        switch self {
        case .enable: return UIImage(systemName: "heart.fill")
        case .disable: return UIImage(systemName: "heart")
        }
    }
}

class PlayerViewModel {
    //MARK: - Properties
    let network = MusicNetworkManager()
    let playableMusic = BehaviorRelay<PlayableMusic?>(value: nil)
    let lyrics = BehaviorRelay<[PlayableMusicLyricInfo]>(value: [])
    let likeStatus = BehaviorRelay<LikeButtonStatus>(value: .disable)
    
    //MARK: - Lifecycle
    
    //MARK: - Methods
    func requestMusicForPlay() {
        self.network.requestPlayableMusic { [weak self] music in
            guard let music = music else { return }
            self?.playableMusic.accept(music)
            self?.lyrics.accept(music.lyrics)
        }
    }
}

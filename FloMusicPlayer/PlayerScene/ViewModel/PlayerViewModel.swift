//
//  PlayerViewModel.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/01.
//

import Foundation
import RxRelay

class PlayerViewModel {
    //MARK: - Properties
    let network = MusicNetworkManager()
    let playableMusic = BehaviorRelay<PlayableMusic?>(value: nil)
    let lyrics = BehaviorRelay<[PlayableMusicLyricInfo]>(value: [])
    
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

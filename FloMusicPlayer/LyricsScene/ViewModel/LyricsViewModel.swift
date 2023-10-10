//
//  LyricsViewModel.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/08.
//

import RxSwift
import RxRelay
import UIKit

class LyricsViewModel {
    //MARK: - Properties
    let lyricViewConfig: LyricsTypeConfig
    let playableMusicInfo: BehaviorRelay<[PlayableMusicLyricInfo]>
    
    let autoScrollStatus = BehaviorRelay<ControlButtonStatus>(value: .enable)
    let tapToSeekStatus = BehaviorRelay<ControlButtonStatus>(value: .disable)
    
    //MARK: - Lifecycle
    init(config: LyricsTypeConfig, dataSource: BehaviorRelay<[PlayableMusicLyricInfo]>) {
        self.lyricViewConfig = config
        self.playableMusicInfo = dataSource
    }
    
    //MARK: - Methods
}

//
//  MusicPlayer.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/28.
//

import AVFoundation

class MusicPlayer {
    //MARK: - Properties
    static let shared = MusicPlayer()
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?

    private var playerItemStatusObserver: NSKeyValueObservation?
    
    var durationTime: CMTime? {
        self.playerItem?.duration
    }
    
    //MARK: - Lifecycle
    private init() {}

    func start(musicUrl: String?, prepareHandler: @escaping () -> Void) {
        guard let music = musicUrl, let url = URL(string: music) else { return }

        self.playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)

        // KVO로 AVPlayerItem의 status 속성을 관찰합니다.
        self.playerItemStatusObserver = playerItem?.observe(\.status, options: [.new], changeHandler: { [weak self] (playerItem, change) in
            if playerItem.status == .readyToPlay {
                self?.player?.play()
                prepareHandler()
            } else if playerItem.status == .failed {
                print("플레이 실패")
                print("Error: \(playerItem.error?.localizedDescription ?? "Unknown error")")
            }
        })
    }
    
    func resume() {
        self.player?.play()
    }
    
    func pause() {
        self.player?.pause()
    }
    
    func stop() {
    }
    
    func seek() {
        let selectedSeconds: Double = 150  // 예를 들면, 슬라이더에서 선택한 값
        let seekTime = CMTime(value: Int64(selectedSeconds), timescale: 1)
        player?.seek(to: seekTime)
    }
}

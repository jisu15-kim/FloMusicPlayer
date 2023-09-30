//
//  MusicPlayer.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/28.
//

import AVFoundation
import RxSwift
import RxRelay

class MusicPlayer {
    //MARK: - Properties
    static let shared = MusicPlayer()
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var timeObserver: Any?
    var secondHandler: ((Int) -> Void)?
    var isSeekProgress: Bool = false
    private var playerRateContext = 0

    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerRateObserver: NSKeyValueObservation?
    
    var playStatus = BehaviorRelay<PlayStatus>(value: .notPlaying)
    
    var durationTime: CMTime? {
        self.playerItem?.duration
    }
    
    //MARK: - Lifecycle
    private init() {}

    func start(musicUrl: String?, prepareHandler: @escaping () -> Void) {
        guard let music = musicUrl, let url = URL(string: music) else { return }

        self.playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)

        // 재생 가능한 시점파악, 재생
        self.playerItemStatusObserver = playerItem?.observe(\.status, options: [.new], changeHandler: { [weak self] (playerItem, change) in
            if playerItem.status == .readyToPlay {
                self?.player?.play()
                prepareHandler()
                self?.setupTimeObserver()
            } else if playerItem.status == .failed {
                print("플레이 실패")
                print("Error: \(playerItem.error?.localizedDescription ?? "Unknown error")")
            }
        })
        
        // player의 rate에 대한 옵저버 (playing or notPlaying)
        self.playerRateObserver = player?.observe(\.rate, options: [.new], changeHandler: { [weak self] player, change in
            if player.rate == 0 {
                // 정지 혹은 일시정지
                self?.playStatus.accept(.notPlaying)
            } else {
                // 정상 재생중
                self?.playStatus.accept(.playing)
            }
        })
    }
    
    func setupTimeObserver() {
        // 현재 재생 시간을 1초 간격으로 업데이트합니다.
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] currentTime in
            if self?.isSeekProgress == false {
                let seconds = Int(CMTimeGetSeconds(currentTime))
                print("🔥\(seconds)")
                self?.secondHandler?(seconds)
            }
        }
    }
    
    func removeTimeObserver() {
        if let observer = timeObserver {
            self.player?.removeTimeObserver(observer)
            self.timeObserver = nil
        }
    }
    
    func resume() {
        self.player?.play()
    }
    
    func pause() {
        self.player?.pause()
    }
    
    func stop() {
        
    }
    
    func seek(seekSecond: Int) {
        self.isSeekProgress = true
        let seekTime = CMTime(value: CMTimeValue(seekSecond), timescale: 1)
        self.player?.currentItem?.seek(to: seekTime, completionHandler: { [weak self] isDone in
            self?.isSeekProgress = false
        })
    }
}

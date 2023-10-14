//
//  PlayButton.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/26.
//

import UIKit
import RxSwift

class PlayerControlButton: UIButton {
    //MARK: - Properties
    private var playButtonType: PlayerControlButtonType
    private var playStatus: PlayStatus {
        return MusicPlayer.shared.playStatus.value
    }
    private let disposeBag = DisposeBag()
    //MARK: - Lifecycle
    init(buttonType: PlayerControlButtonType) {
        self.playButtonType = buttonType
        super.init(frame: .zero)
        self.addTarget(self, action: #selector(didButtonTapped), for: .touchUpInside)
        self.tintColor = .white
        
        if buttonType == .play {
            self.bindStatus()
        } else {
            // 아닌경우 이미지 설정
            self.setImage(buttonType.getButtonImage(), for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Bind(Play 버튼인 경우만)
    private func bindStatus() {
        MusicPlayer.shared.playStatus
            .bind { [weak self] status in
                guard let self = self else { return }
                self.setImage(self.playButtonType.getButtonImage(playStatus: status), for: .normal)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Methods
    @objc private func didButtonTapped() {
        self.playButtonType.buttonAction(playStatus: self.playStatus)
    }
}

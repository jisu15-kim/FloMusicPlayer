//
//  ViewController.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/26.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    //MARK: - Properties
    let controlPanel: [PlayerControlButtonType] = [.repeat, .backward, .play, .forward, .playOrder]
    let seekbar = PlayerSeekbar()
    
    lazy var tempButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("TEMP BUTTON", for: .normal)
        button.addTarget(self, action: #selector(nextView), for: .touchUpInside)
        return button
    }()
    
    @objc private func nextView() {
        let lyricsVC = LyricsController(currentTimelineWidth: seekbar.timelineView.frame.width)
        self.present(lyricsVC, animated: false)
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.seekbar.setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let url = "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com/2020-flo/music.mp3"
        self.seekbar.configureTimelineWidth()
        MusicPlayer.shared.start(musicUrl: url) { [weak self] in
            self?.seekbar.configureSeekbar()
        }
    }
    
    //MARK: - Methods
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        self.controlPanel.forEach {
            stackView.addArrangedSubview($0.getButton)
        }
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(70)
        }
        
        self.view.addSubview(self.seekbar)
        self.seekbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.bottom.equalTo(stackView.snp.top)
            $0.height.equalTo(40)
        }
        
        self.view.addSubview(self.tempButton)
        self.tempButton.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

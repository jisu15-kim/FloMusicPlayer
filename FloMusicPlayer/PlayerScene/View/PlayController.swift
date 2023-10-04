//
//  ViewController.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/26.
//

import UIKit
import SnapKit
import RxGesture
import RxSwift

class PlayController: UIViewController {
    //MARK: - Properties
    let viewModel = PlayerViewModel()
    let disposeBag = DisposeBag()
    
    let controlPanel: [PlayerControlButtonType] = [.repeat, .backward, .play, .forward, .playOrder]
    let seekbar = PlayerSeekbar()
    let footerStackView = PlayerFooterStackView()
    
    lazy var lyricsTableView = LyricsTableView(config: .inPlayerView, dataSource: self.viewModel.lyrics)
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bind()
    }
    
    //MARK: - Bind
    private func bind() {
        self.viewModel.playableMusic
            .bind { [weak self] music in
                guard let self = self,
                      let music = music else { return }
                MusicPlayer.shared.start(musicUrl: music.file) {
                    self.seekbar.configureSeekbar()
                }
            }
            .disposed(by: disposeBag)
        
        self.lyricsTableView.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                let lyricsVC = LyricsController(currentTimelineWidth: seekbar.timelineView.frame.width, viewModel: self.viewModel)
                self.present(lyricsVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        self.viewModel.requestMusicForPlay()
    }
    
    //MARK: - Methods
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(self.footerStackView)
        self.footerStackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(30)
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        
        self.controlPanel.forEach {
            stackView.addArrangedSubview($0.getButton)
        }
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.footerStackView.snp.top).inset(-5)
            $0.height.equalTo(70)
        }
        
        self.view.addSubview(self.seekbar)
        self.seekbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(stackView.snp.top).inset(10)
            $0.height.equalTo(40)
        }
        
        self.view.addSubview(self.lyricsTableView)
        self.lyricsTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(seekbar.snp.top).inset(-50)
            $0.height.equalTo(40)
        }
    }
}


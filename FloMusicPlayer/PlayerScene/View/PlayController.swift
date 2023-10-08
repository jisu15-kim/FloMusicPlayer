//
//  ViewController.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/26.
//

import UIKit
import Kingfisher
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
    
    lazy var lyricsTableView = LyricsTableView(viewModel: .init(config: .inPlayerView, dataSource: self.viewModel.lyrics))
    
    let albumCoverImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var playerInfoView = PlayerInfoView(textAlignment: .center)
    
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
                // 음악 컨트롤
                MusicPlayer.shared.start(musicUrl: music.file) {
                    self.seekbar.configureSeekbar()
                }
                
                // 곡명, 아티스트명
                self.playerInfoView.configureData(musicTitle: music.title, artistName: music.singer)
                
                // 이미지
                self.albumCoverImageView.kf.indicatorType = .activity
                let imageUrl = URL(string: music.image)
                self.albumCoverImageView.kf.setImage(with: imageUrl)
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
        
        self.view.addSubview(self.albumCoverImageView)
        let size = self.view.frame.width - 40 * 2
        self.albumCoverImageView.snp.makeConstraints {
            $0.bottom.equalTo(self.lyricsTableView.snp.top).inset(-30)
            $0.width.height.equalTo(size)
            $0.centerX.equalToSuperview()
        }
        
        self.view.addSubview(self.playerInfoView)
        self.playerInfoView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(self.albumCoverImageView.snp.top).inset(-16)
        }
    }
}


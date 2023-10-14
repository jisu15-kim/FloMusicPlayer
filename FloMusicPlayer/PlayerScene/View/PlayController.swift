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
    private let viewModel = PlayerViewModel()
    private let disposeBag = DisposeBag()
    
    private let controlPanel: [PlayerControlButtonType] = [.repeat, .backward, .play, .forward, .playOrder]
    private let seekbar = PlayerSeekbar()
    private let footerStackView = PlayerFooterStackView()
    
    private lazy var lyricsTableView = LyricsTableView(viewModel: .init(config: .inPlayerView, dataSource: self.viewModel.lyrics))
    
    private let albumCoverImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .clear
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let playerInfoView = PlayerInfoView(textAlignment: .center)
    
    private lazy var likeButton = self.getToggleButton(image: UIImage(systemName: "heart"))
    private lazy var moreButton = self.getToggleButton(image: UIImage(systemName: "ellipsis"), isRotate: true)
    
    private lazy var actionButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [likeButton, moreButton])
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.lyricsTableView.bind()
    }
    
    //MARK: - Bind
    private func bind() {
        // 음악 데이터 바인딩
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
        
        // 가사 터치 이벤트
        self.lyricsTableView.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                let lyricsVC = LyricsController(currentTimelineWidth: self.seekbar.timelineView.frame.width, viewModel: self.viewModel)
                self.present(lyricsVC, animated: false)
            }
            .disposed(by: disposeBag)
        
        // 버튼 탭 했을 때 status 변경
        self.likeButton.rx.tap
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                let targetStatus: LikeButtonStatus = self.viewModel.likeStatus.value == .enable ? .disable : .enable
                self.viewModel.likeStatus.accept(targetStatus)
            }
            .disposed(by: disposeBag)
        
        // 좋아요 status 바인딩
        self.viewModel.likeStatus
            .bind { [weak self] status in
                self?.likeButton.setImage(status.buttonImage, for: .normal)
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
        
        let buttonStack = self.controlPanel.map { $0.getButton }
        let playerControlStackView = UIStackView(arrangedSubviews: buttonStack)
        playerControlStackView.axis = .horizontal
        playerControlStackView.distribution = .equalCentering
        
        self.view.addSubview(playerControlStackView)
        playerControlStackView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.bottom.equalTo(self.footerStackView.snp.top).inset(-5)
            $0.height.equalTo(70)
        }
        
        self.view.addSubview(self.seekbar)
        self.seekbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(playerControlStackView.snp.top).inset(10)
            $0.height.equalTo(40)
        }
        
        self.view.addSubview(self.actionButtonStackView)
        self.actionButtonStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.seekbar.snp.top).inset(-25)
        }
        
        self.view.addSubview(self.lyricsTableView)
        self.lyricsTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(actionButtonStackView.snp.top).inset(-50)
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
    
    private func getToggleButton(image: UIImage?, isRotate: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        let size = CGFloat(40)
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: size - 15).isActive = true
        button.widthAnchor.constraint(equalToConstant: size).isActive = true
        button.setImage(image, for: .normal)
        button.tintColor = .white
        if isRotate {
            button.transform = button.transform.rotated(by: .pi/2)
        }
        return button
    }
}


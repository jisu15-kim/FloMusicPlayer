//
//  LyricsController.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/30.
//

import UIKit
import RxSwift

class LyricsController: UIViewController {
    //MARK: - Properties
    private let controlPanel: [PlayerControlButtonType] = [.repeat, .backward, .play, .forward, .playOrder, .playList]
    private let seekbar: PlayerSeekbar
    private let viewModel: PlayerViewModel
    private let disposeBag = DisposeBag()
    
    private let playerInfoView = PlayerInfoView(textAlignment: .left)
    lazy var lyricsTableView = LyricsTableView(viewModel: .init(config: .inLyricView, dataSource: self.viewModel.lyrics), delegate: self)
    
    //MARK: - Lifecycle
    init(currentTimelineWidth: CGFloat? = nil, viewModel: PlayerViewModel) {
        self.seekbar = PlayerSeekbar(isShowTimeInfo: false)
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDismissButton(inset: 16)
        self.setupUI()
        self.bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.seekbar.configureSeekbar()
        self.lyricsTableView.bind()
    }
    
    //MARK: - Bind
    private func bind() {
        self.viewModel.playableMusic
            .bind { [weak self] music in
                // 곡명, 아티스트명
                guard let self = self,
                      let music = music else { return }
                self.playerInfoView.configureData(musicTitle: music.title, artistName: music.singer)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Methods
    private func setupUI() {
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(self.playerInfoView)
        self.playerInfoView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(10)
        }
        
        let buttonStack = self.controlPanel.map { $0.getButton }
        let stackView = UIStackView(arrangedSubviews: buttonStack)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(40)
        }

        self.view.addSubview(self.lyricsTableView)
        self.lyricsTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(stackView.snp.top).inset(-50)
            $0.top.equalTo(self.playerInfoView.snp.bottom).inset(-30)
        }
        
        self.view.addSubview(self.seekbar)
        self.seekbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(stackView.snp.top)
            $0.height.equalTo(40)
        }
    }
}

extension LyricsController: LyricsTableViewDelegate {
    func needViewDismiss() {
        self.dismiss(animated: false)
    }
}

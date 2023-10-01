//
//  LyricsController.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/30.
//

import UIKit

class LyricsController: UIViewController {
    //MARK: - Properties
    let controlPanel: [PlayerControlButtonType] = [.repeat, .backward, .play, .forward, .playOrder, .playList]
    let seekbar: PlayerSeekbar
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "가사 들어갈 예정"
        return label
    }()
    
    //MARK: - Lifecycle
    init(currentTimelineWidth: CGFloat? = nil) {
        self.seekbar = PlayerSeekbar(isShowTimeInfo: false)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.seekbar.configureSeekbar()
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
            $0.height.equalTo(40)
        }
        
        self.view.addSubview(self.seekbar)
        self.seekbar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(stackView.snp.top)
            $0.height.equalTo(40)
        }
        
        self.view.addSubview(self.label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}

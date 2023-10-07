//
//  LyricsTableView.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/01.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class LyricsTableView: UIView {
    //MARK: - Properties
    let viewModel: LyricsViewModel
    var currentHighlitingIndex: Int?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = self.viewModel.lyricViewConfig.isScrollEnable
        tableView.register(LyricsCell.self, forCellReuseIdentifier: LyricsCell.identifier)
        return tableView
    }()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle
    init(viewModel: LyricsViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        self.viewModel.playableMusicInfo
            .bind(to: self.tableView.rx.items) { [weak self] tableView, index, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LyricsCell.identifier, for: IndexPath(row: index, section: 0)) as? LyricsCell else { return UITableViewCell() }
                cell.lyricsConfig = self?.viewModel.lyricViewConfig
                cell.lyricItem = item
                if self?.currentHighlitingIndex == index {
                    cell.configureHighlight(isHighlight: true)
                }
                cell.selectionStyle = .none
                return cell
            }
            .disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(PlayableMusicLyricInfo.self)
            .bind { lyric in
                guard let second = lyric.second else { return }
                MusicPlayer.shared.seek(seekSecond: second)
            }
            .disposed(by: disposeBag)
        
        MusicPlayer.shared.currentSecond
            .bind { [weak self] second in
                self?.configureTimecode(currentSecond: second)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Methods
    private func setupUI() {
        self.backgroundColor = .clear
        
        self.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        if self.viewModel.lyricViewConfig == .inLyricView {
            let buttonStack = LyricsControlButtonStackView()
            self.addSubview(buttonStack)
            buttonStack.snp.makeConstraints {
                $0.trailing.top.equalToSuperview()
                $0.width.height.equalTo(30)
            }
        }
    }
    
    // 옵저버에서 획득한 초에 맞는 가사를 꺼냄
    private func configureTimecode(currentSecond: Double) {
        let lyrics = self.viewModel.playableMusicInfo.value
        
        var currentLyric: PlayableMusicLyricInfo?
        var currentIndex: Int?
        
        for (index, lyric) in lyrics.enumerated() {
            if let second = lyric.second, currentSecond >= second {
                currentLyric = lyric
                currentIndex = index
            } else {
                break
            }
        }
        
        self.setLyricCellHighlight(index: currentIndex, lyric: currentLyric)
        self.currentHighlitingIndex = currentIndex
    }
    
    // 하이라이트 할 index와 가사를 세팅
    private func setLyricCellHighlight(index: Int?, lyric: PlayableMusicLyricInfo?) {
        // 데이터가 있다면?
        guard let index = index,
              let lyric = lyric else {
            // 데이터가 없다면 가사가 나오기도 전 이라는 것 -> 맨 처음으로 이동
            if !self.viewModel.lyricViewConfig.isScrollEnable {
                self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            return
        }
        
//        print("현재 가사: \(lyric.lyric), Index: \(index)")
        
        if !self.viewModel.lyricViewConfig.isScrollEnable {
            self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        }
        
        /// 현재 보여지는 셀 for문 돌려서
        /// 현재의 가사인 경우 하이라이트 enable, 아닌 경우 disable
        for cell in self.tableView.visibleCells {
            guard let cell = cell as? LyricsCell else { return }
            let isHighlight = cell.lyricItem?.second == lyric.second
            cell.configureHighlight(isHighlight: isHighlight)
        }
    }
}

extension LyricsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.lyricViewConfig.heightForRowAt
    }
}

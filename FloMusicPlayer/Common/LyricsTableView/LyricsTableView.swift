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

class LyricsTableView: UITableView {
    //MARK: - Properties
    let playableMusicInfo: BehaviorRelay<[PlayableMusicLyricInfo]>
    var currentHighlitingIndex: Int?
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle
    init(dataSource: BehaviorRelay<[PlayableMusicLyricInfo]>) {
        self.playableMusicInfo = dataSource
        super.init(frame: .zero, style: .plain)
        self.delegate = self
        self.separatorStyle = .none
        self.isScrollEnabled = false
        self.register(LyricsCell.self, forCellReuseIdentifier: LyricsCell.identifier)
        self.setupUI()
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        self.playableMusicInfo
            .bind(to: self.rx.items) { tableView, index, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: LyricsCell.identifier, for: IndexPath(row: index, section: 0)) as? LyricsCell else { return UITableViewCell() }
                cell.lyricItem = item
                if self.currentHighlitingIndex == index {
                    cell.configureHighlight(isHighlight: true)
                }
                cell.selectionStyle = .none
                return cell
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
    }
    
    // 옵저버에서 획득한 초에 맞는 가사를 꺼냄
    private func configureTimecode(currentSecond: Double) {
        let lyrics = self.playableMusicInfo.value
        
        var currentLyric: PlayableMusicLyricInfo?
        var currentIndex: Int?
        
        for (index, lyric) in lyrics.enumerated() {
            if let second = lyric.second, currentSecond > second {
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
            // 데이터가 없다면 맨 처음으로 이동
            self.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            return
        }
        
        print("현재 가사: \(lyric.lyric), Index: \(index)")
        
        self.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        /// 현재 보여지는 셀 for문 돌려서
        /// 현재의 가사인 경우 하이라이트 enable, 아닌 경우 disable
        for cell in self.visibleCells {
            guard let cell = cell as? LyricsCell else { return }
            let isHighlight = cell.lyricItem?.second == lyric.second
            cell.configureHighlight(isHighlight: isHighlight)
        }
    }
}

extension LyricsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
}

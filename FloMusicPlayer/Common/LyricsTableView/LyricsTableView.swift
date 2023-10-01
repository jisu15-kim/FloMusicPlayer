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
    private let disposeBag = DisposeBag()
    //MARK: - Lifecycle
    init(dataSource: BehaviorRelay<[PlayableMusicLyricInfo]>) {
        self.playableMusicInfo = dataSource
        super.init(frame: .zero, style: .plain)
        self.delegate = self
        self.separatorStyle = .none
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
        
        guard let currentIndex = currentIndex,
              let currentLyric = currentLyric else { return }
        
        print("현재 가사: \(currentLyric.lyric), Index: \(currentIndex)")
        
        self.scrollToRow(at: IndexPath(row: currentIndex, section: 0), at: .top, animated: true)
    }
}

extension LyricsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
}

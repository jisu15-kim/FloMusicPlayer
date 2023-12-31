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
    weak var delegate: LyricsTableViewDelegate?
    let viewModel: LyricsViewModel
    var currentHighlitingIndex: Int?
    var isAnimatingScroll = false
    
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
    init(viewModel: LyricsViewModel, delegate: LyricsTableViewDelegate? = nil) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    func bind() {
        // DataSource 바인딩
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
        
        // 유저 가사 탭 인터랙션 바인딩
        self.tableView.rx.modelSelected(PlayableMusicLyricInfo.self)
            .bind { [weak self] lyric in
                guard let self = self else { return }
                
                if self.viewModel.tapToSeekStatus.value == .enable {
                    guard let second = lyric.second else { return }
                    MusicPlayer.shared.seek(seekSecond: second)
                } else {
                    self.delegate?.needViewDismiss()
                }
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
        
        if self.viewModel.lyricViewConfig == .inPlayerView {
            self.tableView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        } else {
            self.tableView.snp.makeConstraints {
                $0.top.bottom.trailing.equalToSuperview()
                $0.leading.equalToSuperview().inset(16)
            }
        }
        
        if self.viewModel.lyricViewConfig == .inLyricView {
            let buttonStack = LyricsControlButtonStackView(
                autoScrollStatus: self.viewModel.autoScrollStatus,
                tapToSeekStatus: self.viewModel.tapToSeekStatus)
            self.addSubview(buttonStack)
            buttonStack.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.top.equalToSuperview()
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
        
        self.configureLyricsScroll(index: currentIndex, lyric: currentLyric)
        self.currentHighlitingIndex = currentIndex
    }
    
    /// 가사 스크롤
    private func configureLyricsScroll(index: Int?, lyric: PlayableMusicLyricInfo?) {
        
        // 오토 스크롤 상태인지 체크
        var isAutoScrollEnable = self.viewModel.lyricViewConfig.isAutoScrollEnable
        if self.viewModel.lyricViewConfig == .inLyricView {
            isAutoScrollEnable = self.viewModel.autoScrollStatus.value.value
        }
        
        // 데이터가 있다면?
        guard let index = index,
              let lyric = lyric else {
            // 데이터가 없다면 가사가 나오기도 전 이라는 것 -> 맨 처음으로 이동
            if isAutoScrollEnable {
                self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            self.configureLyricsHighlight(targetLyric: nil)
            return
        }
        
        // 오토 스크롤 상태일 때 && 중복 스크롤이 불리지 않도록 방어
        if isAutoScrollEnable && !self.isAnimatingScroll {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let self = self else { return }
                self.isAnimatingScroll = true
                self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: self.viewModel.lyricViewConfig.authScrollposition, animated: true)
            }) { [weak self] _ in
                self?.isAnimatingScroll = false
            }
        }
        
        self.configureLyricsHighlight(targetLyric: lyric)
    }
    
    /// 가사 하이라이팅
    private func configureLyricsHighlight(targetLyric: PlayableMusicLyricInfo?) {
        /// 현재 보여지는 셀 for문 돌려서
        /// 현재의 가사인 경우 하이라이트 enable, 아닌 경우 disable
        for cell in self.tableView.visibleCells {
            guard let cell = cell as? LyricsCell else { return }
            let isHighlight = cell.lyricItem?.second == targetLyric?.second
            cell.configureHighlight(isHighlight: isHighlight)
        }
    }
}

extension LyricsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.lyricViewConfig.heightForRowAt
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.viewModel.autoScrollStatus.accept(.disable)
    }
}

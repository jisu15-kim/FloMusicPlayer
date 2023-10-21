//
//  Seekbar.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/09/26.
//

import UIKit
import RxSwift
import RxRelay
import RxGesture
import AVFoundation

class PlayerSeekbar: UIView {
    //MARK: - Properties
    /// 남은 타임라인 길이 뷰
    let leftTimelineView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray.withAlphaComponent(0.3)
        return view
    }()
    
    /// 위를 덮는 실제 타임라인 뷰
    let timelineView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemIndigo
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 타임라인의 스택뷰
    lazy var timeLineStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [self.timelineView, self.leftTimelineView])
        stack.axis = .horizontal
        stack.spacing = 0
        stack.distribution = .fill
        return stack
    }()
    
    let currentPlaybackTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemIndigo
        label.textAlignment = .left
        label.text = "00:00"
        return label
    }()
    
    let durationTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemGray
        label.textAlignment = .right
        label.text = "00:00"
        return label
    }()
    
    let seekTimecode: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .heavy)
        label.textAlignment = .center
        label.text = "00:00"
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    /// 현재 시간과 총 시간 표시 여부
    let isShowTimeInfo: Bool
    /// 실제 타임라인의 width
    lazy var timeLineWidthConstraint = self.timelineView.widthAnchor.constraint(equalToConstant: 0)
    /// SeekTimeCode의 width
    var seekTimecodeWidth: CGFloat {
        return self.seekTimecode.frame.width
    }
    /// 타임라인의 총 width
    var totalTimelineWidth: CGFloat {
        return self.timeLineStackView.frame.width
    }
    /// 타임라인의 position
    let timelinePoint = PublishRelay<CGFloat>()
    var lastTappedPoint: CGFloat = 0
    /// 타임라인 탭 여부
    let isTimelineTapped: BehaviorRelay<Bool?>
    /// 타임라인의 position을 초 단위로 환산
    var secondTimelineTapped: Int? {
        guard let totalSecond = self.musicDuration else { return nil }
        let ratio = self.totalTimelineWidth / self.lastTappedPoint
        let tappedSecond = Int(totalSecond / ratio)
        return tappedSecond
    }
    /// 총 길이
    var musicDuration: Double? {
        guard let duration = MusicPlayer.shared.durationTime else { return nil }
        let totalSeconds = CMTimeGetSeconds(duration)
        return Double(totalSeconds)
    }
    /// 현재 재생중인 초
    var currentSecond: Int {
        return Int(MusicPlayer.shared.currentSecond.value)
    }
    
    //MARK: - Lifecycle
    init(isShowTimeInfo: Bool = true) {
        self.isShowTimeInfo = isShowTimeInfo
        self.isTimelineTapped = BehaviorRelay(value: nil)
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    func bind() {
        /// AVPlayer에서 받아온 플레이중인 현재 시간 바인딩
        /// -> 현재 재생중인 시간 에 적용
        MusicPlayer.shared.currentSecond
            .bind { [weak self] second in
                guard let self = self else { return }
                // 현재시간 변경
                let timecode = self.secondToTimecode(second: Int(second))
                self.currentPlaybackTimeLabel.text = timecode
            }
            .disposed(by: disposeBag)
        
        /// AVPlayer에서 받아온 Playback 비율 바인딩
        /// -> 타임라인 뷰 width에 적용
        MusicPlayer.shared.currentPlaybackRatio
            .bind { [weak self] ratio in
                guard let self = self,
                      self.isTimelineTapped.value != true else { return }
                let width = self.totalTimelineWidth * CGFloat(ratio)
                self.timeLineWidthConstraint.constant = width
            }
            .disposed(by: disposeBag)
        
        // 유저 인터랙션으로 이동되는 타임라인을 바인딩
        self.timelinePoint
            .bind { [weak self] point in
                guard let self = self else { return }
                self.lastTappedPoint = point
                // 타임라인 위치 설정
                self.timeLineWidthConstraint.constant = point
                // 타임코드 가 슬라이드를 따라가도록 설정
                self.configureTimecodePosition(tapPoint: point)
                // 지금 터치한 곳의 초 구하기
                guard let tappedSecond = self.secondTimelineTapped else { return }
                // 타임코드 텍스트에 넣기
                self.configureTimecodeString(withTappedSecond: tappedSecond)
            }
            .disposed(by: disposeBag)
        
        // 타임라인 제스처 탭 이벤트
        self.isTimelineTapped
            .bind { [weak self] isTapped in
                guard let self = self,
                      let isTapped = isTapped else { return }
                self.configureTimelineTapped(isTapped: isTapped)
                self.seekTimecode.isHidden = !isTapped
                
                // 플레이 되고 있는 음악 컨트롤하기 (타임라인에서 손을 뗄 때)
                if let tappedSecond = self.secondTimelineTapped,
                   isTapped == false {
                    MusicPlayer.shared.seek(seekSecond: Double(tappedSecond))
                }
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Touch Control Methods
    // 터치 허용 영역 처리
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 타임라인의 rect만 터치를 허용함
        if !self.timeLineStackView.frame.contains(point) {
            return nil
        }
        return super.hitTest(point, with: event)
    }
    
    // 터치 시작
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.isTimelineTapped.accept(true)
        self.acceptTimeline(withTouch: touches.first)
    }
    
    // 터치 후 이동
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        self.acceptTimeline(withTouch: touches.first)
    }
    
    // 손을 뗏을 때
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.isTimelineTapped.accept(false)
    }
    
    // 터치가 중단됐을 때 (예: 전화가 오는 경우 등)
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.isTimelineTapped.accept(false)
    }
    
    //MARK: - Methods
    func setupUI() {
        // 시작시간
        self.addSubview(self.currentPlaybackTimeLabel)
        self.currentPlaybackTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        // 종료시간
        self.addSubview(self.durationTimeLabel)
        self.durationTimeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        // 타임라인 스택뷰
        self.addSubview(self.timeLineStackView)
        self.timeLineStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.currentPlaybackTimeLabel.snp.top).inset(-5)
            $0.height.equalTo(5)
        }
        
        self.addSubview(self.seekTimecode)
        self.seekTimecode.snp.makeConstraints {
            $0.centerX.equalTo(self.timeLineStackView)
            $0.bottom.equalTo(self.timeLineStackView.snp.top).inset(-8)
        }
        self.timeLineWidthConstraint.isActive = true
        
        if isShowTimeInfo {
            self.currentPlaybackTimeLabel.isHidden = false
            self.durationTimeLabel.isHidden = false
        } else {
            self.currentPlaybackTimeLabel.isHidden = true
            self.durationTimeLabel.isHidden = true
        }
    }
    
    func configureSeekbar() {
        self.bind()
        self.timeLineWidthConstraint.isActive = true
        guard let duration = self.musicDuration else { return }
        self.durationTimeLabel.text = self.secondToTimecode(second: Int(duration))
        print("👉 seekbar Width: \(self.frame.width)")
    }
    
    private func acceptTimeline(withTouch touch: UITouch?) {
        guard let touch = touch else { return }
        // 타임라인의 전체 길이
        let timelineWidth = self.timeLineStackView.frame.width
        // 현재 탭한 타임라인의 위치
        let tappedPoint = touch.location(in: self.timeLineStackView).x
        // 0과 timelineWidth (예: 300) 사이의 값으로 currentTimelinePoint 제한
        let currentTimelinePoint = min(max(0, tappedPoint), timelineWidth)
        self.timelinePoint.accept(currentTimelinePoint)
    }
    
    private func configureTimelineTapped(isTapped: Bool) {
        if isTapped {
            self.timeLineStackView.snp.updateConstraints { $0.height.equalTo(15) }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layoutIfNeeded()
            }
        } else {
            self.timeLineStackView.snp.updateConstraints { $0.height.equalTo(5) }
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.layoutIfNeeded()
            }
        }
    }
    
    /// 타임라인 탭 했을 때 나오는 타임코드의 위치 이동
    private func configureTimecodePosition(tapPoint: CGFloat) {
        let timecodeCenterPosition = self.timeLineStackView.frame.width / 2
        
        let min = -timecodeCenterPosition + self.seekTimecodeWidth / 2
        let max = timecodeCenterPosition - self.seekTimecodeWidth / 2
        
        // 적용할 Offset에서 최소값, 최대값 설정
        var centerOffset = -(timecodeCenterPosition - tapPoint)
        centerOffset = centerOffset < min ? min : centerOffset
        centerOffset = centerOffset > max ? max : centerOffset
        
        // 위치 업데이트
        self.seekTimecode.snp.updateConstraints {
            $0.centerX.equalTo(self.timeLineStackView).offset(centerOffset)
        }
    }
    
    /// 타임라인 탭 했을 때 나오는 타임코드의 텍스트 변경
    private func configureTimecodeString(withTappedSecond second: Int) {
        self.seekTimecode.text = secondToTimecode(second: second)
    }
    
    private func secondToTimecode(second: Int) -> String {
        let minutes = second / 60
        let seconds = second % 60
        let formattedString = String(format: "%02d:%02d", minutes, seconds)
        return formattedString
    }
    
    private func secondToTimelineWidth(second: Int) -> CGFloat {
        guard let totalSecond = self.musicDuration else { return .zero }
        let ratio = totalSecond / Double(second)
        let timelineWidth = self.totalTimelineWidth / ratio
        return timelineWidth
    }
}

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
    /// 백그라운드의 회색 타임라인
    let leftTimelineView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray.withAlphaComponent(0.3)
        return view
    }()
    
    /// 위를 덮는 실제 타임라인
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
    
    let startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemIndigo
        label.textAlignment = .left
        label.text = "00:00"
        return label
    }()
    
    let endTimeLabel: UILabel = {
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
        return label
    }()
    
    private let disposeBag = DisposeBag()
    
    /// 실제 타임라인의 width
    lazy var timeLineWidthConstraint = self.timelineView.widthAnchor.constraint(equalToConstant: 0)
    
    var seekTimecodeWidth: CGFloat {
        return self.seekTimecode.frame.width
    }
    
    var totalTimelineWidth: CGFloat {
        return self.timeLineStackView.frame.width
    }
    
    /// 타임라인의 position
    let timelinePoint: BehaviorRelay<CGFloat>
    /// 타임라인 탭 여부
    let isTimelineTap: BehaviorRelay<Bool>
    /// 총 길이
    var totalSecond: Double?
    
    //MARK: - Lifecycle
    init() {
        self.timelinePoint = BehaviorRelay(value: 0)
        self.isTimelineTap = BehaviorRelay(value: false)
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    func bind() {
        self.timelinePoint
            .bind { [weak self] point in
                guard let self = self else { return }
                // 타임라인 설정
                self.timeLineWidthConstraint.constant = point
                // 타임코드 설정
                self.configureTimecodePosition(tapPoint: point)
                self.configureTimecodeString(tapPoint: point)
            }
            .disposed(by: disposeBag)
        
        self.isTimelineTap
            .bind { [weak self] isTapped in
                self?.configureTimelineTapped(isTapped: isTapped)
                self?.seekTimecode.isHidden = !isTapped
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
        self.isTimelineTap.accept(true)
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
        self.isTimelineTap.accept(false)
    }
    
    // 터치가 중단됐을 때 (예: 전화가 오는 경우 등)
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.isTimelineTap.accept(false)
    }
    
    //MARK: - Methods
    private func setupUI() {
        // 시작시간
        self.addSubview(self.startTimeLabel)
        self.startTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview()
        }
        
        // 종료시간
        self.addSubview(self.endTimeLabel)
        self.endTimeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview()
        }
        
        // 타임라인 스택뷰
        self.addSubview(self.timeLineStackView)
        self.timeLineStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(5)
            $0.bottom.equalTo(self.startTimeLabel.snp.top).inset(-5)
            $0.height.equalTo(5)
        }
        
        self.addSubview(self.seekTimecode)
        self.seekTimecode.snp.makeConstraints {
            $0.centerX.equalTo(self.timeLineStackView)
            $0.bottom.equalTo(self.timeLineStackView.snp.top).inset(-8)
        }
        
        // 타임라인 Width 0 으로 설정
        self.timeLineWidthConstraint.isActive = true
        self.timeLineWidthConstraint.constant = 40
    }
    
    func configurePlayer() {
        guard let cmDuration = MusicPlayer.shared.durationTime else { return }
        let duration = cmTimeToTimecode(cmTime: cmDuration)
        self.endTimeLabel.text = duration
    }
    
    private func cmTimeToTimecode(cmTime: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(cmTime)
        self.totalSecond = Double(totalSeconds)
        let minutes = Int(totalSeconds / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        let formattedString = String(format: "%02d:%02d", minutes, seconds)
        return formattedString
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
    private func configureTimecodeString(tapPoint: CGFloat) {
        guard let totalSecond = self.totalSecond else { return }
        let ratio = self.totalTimelineWidth / tapPoint
        let tappedSecond = Int(totalSecond / ratio)
        let timecode = secondToTimecode(second: tappedSecond)
        self.seekTimecode.text = timecode
    }
    
    
    private func secondToTimecode(second: Int) -> String {
        let minutes = second / 60
        let seconds = second % 60
        let formattedString = String(format: "%02d:%02d", minutes, seconds)
        return formattedString
    }
}

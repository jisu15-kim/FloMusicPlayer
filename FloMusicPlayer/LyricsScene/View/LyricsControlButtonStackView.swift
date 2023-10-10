//
//  LyricsControlButtonStackView.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/05.
//

import UIKit
import RxRelay
import RxSwift

enum ControlButtonStatus {
    case enable
    case disable
    
    var tintColor: UIColor {
        switch self {
        case .enable: return .systemIndigo
        case .disable: return .darkGray
        }
    }
    
    var value: Bool {
        switch self {
        case .enable: return true
        case .disable: return false
        }
    }
}

class LyricsControlButtonStackView: UIStackView {
    //MARK: - Properties
    let autoScrollStatus: BehaviorRelay<ControlButtonStatus>
    lazy var autoScrollButton = self.getToggleImageView(image: UIImage(systemName: "scope"))
    
    let tapToSeekStatus: BehaviorRelay<ControlButtonStatus>
    lazy var tapToSeekButton = self.getToggleImageView(image: UIImage(systemName: "text.justify"))
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Lifecycle
    init(autoScrollStatus: BehaviorRelay<ControlButtonStatus>,
         tapToSeekStatus: BehaviorRelay<ControlButtonStatus>) {
        self.autoScrollStatus = autoScrollStatus
        self.tapToSeekStatus = tapToSeekStatus
        super.init(frame: .zero)
        self.axis = .vertical
        self.spacing = 20
        self.addArrangedSubview(self.autoScrollButton)
        self.addArrangedSubview(self.tapToSeekButton)
        self.bind()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Bind
    private func bind() {
        self.autoScrollStatus
            .bind { [weak self] status in
                self?.autoScrollButton.tintColor = status.tintColor
            }
            .disposed(by: disposeBag)
        
        self.tapToSeekStatus
            .bind { [weak self] status in
                self?.tapToSeekButton.tintColor = status.tintColor
            }
            .disposed(by: disposeBag)
        
        self.autoScrollButton.rx.tapGesture()
            .when(.recognized)
            .subscribe { [weak self] _ in
                if self?.autoScrollStatus.value == .disable {
                    self?.autoScrollStatus.accept(.enable)
                } else {
                    self?.autoScrollStatus.accept(.disable)
                }
            }
            .disposed(by: disposeBag)
        
        self.tapToSeekButton.rx.tapGesture()
            .when(.recognized)
            .subscribe { [weak self] _ in
                if self?.tapToSeekStatus.value == .disable {
                    self?.tapToSeekStatus.accept(.enable)
                } else {
                    self?.tapToSeekStatus.accept(.disable)
                }
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - Methods
    private func getToggleImageView(image: UIImage?) -> UIImageView {
        let view = UIImageView()
        let size = CGFloat(40)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: size - 15).isActive = true
        view.widthAnchor.constraint(equalToConstant: size).isActive = true
        view.image = image
        return view
    }
}

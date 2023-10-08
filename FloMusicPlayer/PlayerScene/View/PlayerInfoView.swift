//
//  PlayerInfoView.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/09.
//

import UIKit

class PlayerInfoView: UIView {
    //MARK: - Properties
    let musicTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "붉은 노을"
        label.font = .boldSystemFont(ofSize: 18)
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "이문세"
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    //MARK: - Lifecycle
    init(textAlignment: NSTextAlignment) {
        super.init(frame: .zero)
        self.musicTitleLabel.textAlignment = textAlignment
        self.artistLabel.textAlignment = textAlignment
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Methods
    private func setupUI() {
        let containerStackView = UIStackView(arrangedSubviews: [musicTitleLabel, artistLabel])
        containerStackView.axis = .vertical
        
        self.addSubview(containerStackView)
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureData(musicTitle: String, artistName: String) {
        self.musicTitleLabel.text = musicTitle
        self.artistLabel.text = artistName
    }
}

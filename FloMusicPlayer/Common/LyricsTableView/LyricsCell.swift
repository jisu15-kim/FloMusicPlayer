//
//  LyricsCell.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/01.
//

import UIKit

class LyricsCell: UITableViewCell {
    //MARK: - Properties
    static let identifier = "LyricsCell"
    
    var lyricsConfig: LyricsTypeConfig?
    
    let lyricLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    var lyricItem: PlayableMusicLyricInfo? {
        didSet {
            self.configure()
        }
    }
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.configureHighlight(isHighlight: false)
    }
    
    //MARK: - Methods
    private func setupUI() {
        self.contentView.addSubview(self.lyricLabel)
        self.lyricLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configure() {
        guard let item = self.lyricItem,
              let config = self.lyricsConfig else { return }
        self.lyricLabel.text = item.lyric
        self.lyricLabel.textAlignment = config.textAlighment
        self.lyricLabel.font = config.lyricFont
    }
    
    func configureHighlight(isHighlight: Bool) {
        if isHighlight {
            self.lyricLabel.textColor = .white
        } else {
            self.lyricLabel.textColor = .darkGray
        }
    }
}

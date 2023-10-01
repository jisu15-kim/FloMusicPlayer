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
    
    let lyricLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
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
    
    //MARK: - Methods
    private func setupUI() {
        self.contentView.addSubview(self.lyricLabel)
        self.lyricLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func configure() {
        guard let item = self.lyricItem else { return }
        self.lyricLabel.text = item.lyric
    }
}

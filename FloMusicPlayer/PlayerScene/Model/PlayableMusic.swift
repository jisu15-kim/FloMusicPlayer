//
//  PlayableMusic.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/01.
//

import Foundation
import CoreMedia

struct PlayableMusic: Codable {
    let singer: String
    let album: String
    let title: String
    let duration: Int
    let image: String
    let file: String
    let lyrics: [PlayableMusicLyricInfo]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.singer = try container.decode(String.self, forKey: .singer)
        self.album = try container.decode(String.self, forKey: .album)
        self.title = try container.decode(String.self, forKey: .title)
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.image = try container.decode(String.self, forKey: .image)
        self.file = try container.decode(String.self, forKey: .file)
        
        let lyricsString = try container.decode(String.self, forKey: .lyrics)
        let lyricsLines = lyricsString.split(separator: "\n")
        
        var lyricInfos: [PlayableMusicLyricInfo] = []
        for line in lyricsLines {
            let components = line.split(separator: "]")
            if components.count == 2 {
                let timecode = String(components[0]).replacingOccurrences(of: "[", with: "")
                let lyric = String(components[1])
                let second = PlayableMusic.convertTimeToDouble(timecode)
                let lyricInfo = PlayableMusicLyricInfo(second: second, lyric: lyric)
                lyricInfos.append(lyricInfo)
            }
        }
        
        lyrics = lyricInfos
    }
    
    static func convertTimeToDouble(_ time: String) -> Double? {
        let components = time.split(separator: ":").map { String($0) }
        
        guard components.count == 3,
              let minutes = Double(components[0]),
              let seconds = Double(components[1]),
              let milliseconds = Double(components[2]) else {
            return nil
        }
        
        let totalSeconds = minutes * 60 + seconds + milliseconds / 1000.0
        return totalSeconds
    }
}

struct PlayableMusicLyricInfo: Codable {
    let second: Double?
    let lyric: String
}

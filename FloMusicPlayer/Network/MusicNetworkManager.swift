//
//  MusicNetworkManager.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/01.
//

import Foundation
import Alamofire

struct MusicNetworkManager {
    func requestPlayableMusic(completion: @escaping (PlayableMusic?) -> Void) {
        guard let path = Bundle.main.path(forResource: "songData", ofType: "json") else {
            return
        }
        
        guard let jsonString = try? String(contentsOfFile: path) else {
            return
        }
        
        let decoder = JSONDecoder()
        let data = jsonString.data(using: .utf8)
        if let data = data,
           let playableMusic = try? decoder.decode(PlayableMusic.self, from: data) {
           completion(playableMusic)
        }
        return
        
        let router = MusicRouter.getPlayableMusic
        print(router.url)
        AF.request(router.url, method: router.method)
            .responseDecodable(of: PlayableMusic.self) { response in
                switch response.result {
                case .success(let result):
                    print(result)
                    completion(result)
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
    }
}

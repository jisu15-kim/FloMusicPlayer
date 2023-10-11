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
        let router = MusicRouter.getPlayableMusic
        
        AF.request(router.url, method: router.method)
            .responseDecodable(of: PlayableMusic.self) { response in
                switch response.result {
                case .success(let result):
                    completion(result)
                case .failure(let error):
                    print(error)
                    completion(nil)
                }
            }
    }
}

//https://drive.google.com/file/d/1GvTXNk3NLDFA1tgkYjMuwZi7ZC5LI1u8/view?usp=drive_link

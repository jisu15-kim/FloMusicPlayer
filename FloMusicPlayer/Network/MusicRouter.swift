//
//  MusicRouter.swift
//  FloMusicPlayer
//
//  Created by 김지수 on 2023/10/01.
//

import Foundation
import Alamofire

enum MusicRouter {
    case getPlayableMusic
    
    var url: String {
        return baseUrlString + path
    }
 
    var baseUrlString: String {
        return "https://grepp-programmers-challenges.s3.ap-northeast-2.amazonaws.com"
    }
    
    var path: String {
        return "/2020-flo/song.json"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}

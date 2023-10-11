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
        return "https://drive.google.com/"
    }
    
    var path: String {
        return "uc?export=view&id=1oL5bdjtz0gPJ5R1oCmQElW9vcW9b5nxp"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}

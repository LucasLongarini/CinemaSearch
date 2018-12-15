//
//  TrailerData.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-27.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

struct JsonVideoData: Decodable {
    var id: Int = 0
    var results: [VideoData] = [VideoData]()
}
struct VideoData: Decodable {
    var type: String = ""
    var name: String = ""
    var key: String = ""
}


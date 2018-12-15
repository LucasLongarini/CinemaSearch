//
//  Episode.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-13.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class Episode: Decodable {
    var airDate:String? = ""
    var episodeNumber: Int = 0
    var name: String = ""
    var overview: String = ""
    var id: Int = 0
    var voteAverage: Float = 0
    var stillPath: String? = nil
}

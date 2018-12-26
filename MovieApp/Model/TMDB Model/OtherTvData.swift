//
//  OtherTvData.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class OtherTvData : Decodable{
    var numberOfEpisodes: Int = 0
    var seasons: [TvSeason] = [TvSeason]()
}

class TvSeason: Decodable{
    var airDate: String? = ""
    var episodeCount: Int = 0
    var id:Int = 0
    var name: String = ""
    var overview: String = ""
    var posterPath:String? = ""
    var seasonNumber: Int = 0
}

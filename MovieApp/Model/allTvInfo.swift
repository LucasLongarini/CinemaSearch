//
//  allTvInfo.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-10-06.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class AllTvInfo:Decodable{
    var numberOfEpisodes: Int = 0
    var seasons: [TvSeason] = [TvSeason]()
    var name: String = ""
    var firstAirDate: String = ""
    var id: Int = 0
    var overview: String = ""
    var backdropPath: String? = ""
    var posterPath: String? = ""
    var voteAverage: Float = 0
}

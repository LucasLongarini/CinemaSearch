//
//  allMovieInfo.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-28.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class AllMoviInfo:Decodable{
    var id: Int = 0
    var title: String = ""
    var overview: String = ""
    var releaseDate: String? = ""
    var voteAverage: Float = 0
    var backdropPath: String? = ""
    var posterPath: String? = ""
    var runtime: Int?
    
}

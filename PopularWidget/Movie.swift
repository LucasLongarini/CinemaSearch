//
//  Movie.swift
//  PopularWidget
//
//  Created by Lucas Longarini on 2018-12-19.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class Movie: Decodable{
    var id: Int = 0
    var title: String = ""
    var overview: String = ""
    var releaseDate: String = ""
    var voteAverage: Float = 0
    var backdropPath: String? = ""
    var posterPath: String? = ""
}

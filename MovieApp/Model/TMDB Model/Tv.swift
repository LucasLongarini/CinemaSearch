//
//  Tv.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-09-09.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class Tv: Decodable {
    
    init() {}
    
    init(id:Int?, name:String?, overview:String?, firstAirDate:String?, voteAverage:Float?, backdropPath: String?, posterPath:String?){
        self.id = id ?? 0
        self.name = name ?? ""
        self.overview = overview ?? ""
        self.firstAirDate = firstAirDate ?? ""
        self.voteAverage = voteAverage ?? 0.0
        self.backdropPath = backdropPath
        self.posterPath = posterPath
    }
    
    var name: String = ""
    var firstAirDate: String = ""
    var id: Int = 0
    var overview: String = ""
    var backdropPath: String? = ""
    var posterPath: String? = ""
    var voteAverage: Float = 0
}

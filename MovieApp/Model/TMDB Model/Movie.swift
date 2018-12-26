//
//  File.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-27.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class Movie: Decodable{
    
    init() {}
    
    init(id:Int?, title:String?, overview:String?, releaseDate:String?, voteAverage:Float?, backdropPath: String?, posterPath:String?){
        self.id = id ?? 0
        self.title = title ?? ""
        self.overview = overview ?? ""
        self.releaseDate = releaseDate ?? ""
        self.voteAverage = voteAverage ?? 0.0
        self.backdropPath = backdropPath
        self.posterPath = posterPath
    }
    
    var id: Int = 0
    var title: String = ""
    var overview: String = ""
    var releaseDate: String = ""
    var voteAverage: Float = 0
    var backdropPath: String? = ""
    var posterPath: String? = ""
}

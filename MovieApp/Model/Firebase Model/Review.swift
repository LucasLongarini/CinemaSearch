//
//  Review.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-24.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

enum ReviewType {
    case Movie
    case Tv
    case Episode
}

class Review{
    
    var reviewType: ReviewType
    var mediaID:Int
    var description:String
    var title:String
    var score:Int
    var time:Date
    var reviewer:User
    
    init(reviewType:ReviewType, mediaID:Int, description:String, title:String, score:Int, time:Date, reviewer:User){
        self.reviewType = reviewType
        self.mediaID = mediaID
        self.description = description
        self.title = title
        if score > 5{self.score = score}else if score < 1 {self.score = 1}
        else{self.score = score}
        self.time = time
        self.reviewer = reviewer
    }
    
}

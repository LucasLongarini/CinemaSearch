//
//  Person.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-30.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class Person: Decodable{
    var id: Int = 0
    var character: String = ""
    var name: String = ""
    var profilePath: String?
}


class PersonCredits{
    init(){
        movies = [Movie]()
        tv = [Tv]()
    }
    var movies:[Movie]?
    var tv:[Tv]?
}

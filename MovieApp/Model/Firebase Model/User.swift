//
//  User.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-22.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class User{
    
    var ID:String
    var name:String
    var profileURL:String?
    var facebookID:Int?
    
    init(){
        ID = ""
        name = ""
        profileURL = nil
        facebookID = nil
    }
    
    init(ID:String, name:String) {
        self.ID = ID
        self.name = name
    }
    
    init(ID:String, name:String, profileURL:String?, facebookID:Int?) {
        self.ID = ID
        self.name = name
        self.profileURL = profileURL
        self.facebookID = facebookID
    }
    
}

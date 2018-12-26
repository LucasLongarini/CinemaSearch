//
//  UserSingleton.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-12-21.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class UserSingleton{
    static var shared = UserSingleton()
    
    var isLoggedIn:Bool
    var user:User?
    var image:UIImage?
    
    func downloadImage(){
        if let facebookID = user?.facebookID{
            let url = URL(string:  "https://graph.facebook.com/\(facebookID)/picture?type=normal")!
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                if let downloadedImage = UIImage(data: data!){
                    self.image = downloadedImage
                }
                
            }.resume()
        }
        else if let profileURL = user?.profileURL{
            let url = URL(string: profileURL)!
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil{
                    print(error!.localizedDescription)
                    return
                }
                if let downloadedImage = UIImage(data: data!){
                    self.image = downloadedImage
                }
                
            }.resume()
        }
    }
    
    init() {
        isLoggedIn = false
        image = UIImage(named: "Person Placeholder Image")
    }
}

//
//  Extentions.swift
//  MovieApp
//
//  Created by Lucas Longarini on 2018-08-28.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class ImageCache{
    static var shared = ImageCache()
    
    let imageCache:NSCache<AnyObject, AnyObject>
    
    init(){
        imageCache = NSCache<AnyObject, AnyObject>()
        imageCache.countLimit = 50
    }
}

extension UIImageView{
    func loadImageUsingCache(urlString:String){
        //check cache for image first
        if let cachedImage = ImageCache.shared.imageCache.object(forKey: urlString as AnyObject) as? UIImage{
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    ImageCache.shared.imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    self.image = downloadedImage
                }
            }
            
        }.resume()
    }
    
}

extension CALayer{
    func addDropShadow(){
        self.shadowOffset = CGSize(width: 0, height: 2.0)
        self.shadowColor = UIColor.black.cgColor
        self.shadowRadius = 3
        self.shadowOpacity = 0.6
        self.masksToBounds = false;
    }
}
extension UIView{
    func addDropShadow(){
        layer.shadowOffset = CGSize(width: 0, height: 2.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false;
        clipsToBounds = false;
    }

    func addCircleShadow(){
            
        let shadowPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: self.layer.cornerRadius)
            
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.5)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 3
        layer.shadowPath = shadowPath.cgPath
    }

}
extension Int{
    func toRunTime() -> String{
        var numberOfHours: Int = 0
        var numberOfMinutes: Int = 0
        numberOfHours = self/60
        numberOfMinutes = self%60
        return "\(numberOfHours)hr \(numberOfMinutes)min"
    }
}
extension String{
    
    func isFutureDate()->Bool{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatterGet.date(from: self){
            if date > Date(){return true}
            else{return false}
        }
        else{
            return false
        }
    }
    
    func changeDateFormating()->String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatterGet.date(from: self){
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMMM dd, yyyy"
            return dateFormatterPrint.string(from: date)
        }else{
            return self
        }
    }
}
